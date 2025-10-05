#include <LiquidCrystal_I2C.h>
#include <DHT.h>
LiquidCrystal_I2C lcd(0x27, 16, 2);
#include <Wire.h>
#include <RTClib.h>
#include <WiFiManager.h>
#include <time.h>
#include <SPIFFS.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Arduino.h>
#include <Preferences.h>

#define PREF_NAMESPACE "wifi"

#define soil 33
#define relay 13
#define relayON LOW
#define relayOFF HIGH
#define ledRed 19
#define ledGreen 18
#define button 16
#define dhtPin 5
#define dhtType DHT11

DHT dht(dhtPin, dhtType);
RTC_DS3231 rtc;

bool pumpIsOn;

// MQTT Setting
WiFiClient espClient;
PubSubClient pubSubClient(espClient);
const char *mqtt_broker = "broker.hivemq.com";
const char *mqtt_username = "";
const char *mqtt_password = "";
const int mqtt_port = 1883;

String device_id = "";

bool ledGreenOn = false;
bool ledRedOn = true;

float soilStart = 0.0, soilEnd = 0.0, mean = 0.0;

String dateTime;

DateTime now;

enum DisplayState
{
  INITIAL,
  HUMIDITY_TEMP,
  SOIL_MOISTURE,
  TIMESTAMP
};

DisplayState currentState = DisplayState::INITIAL;

unsigned long previousDisplayMillis = 0;
const long displayInterval = 4000;

char daysOfTheWeek[7][12] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

// Server NTP
const char *ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 0;
const int daylightOffset_sec = 7 * 3600; // gmt+7

WiFiManager wm;
const char *wifiFile = "/wifi_list.json";
const int MAX_RETRY = 5;

unsigned long lastReconnectAttempt = 0;
int countReconnect = 0;

// MQTT
int control_by = 0;
float lastTemperature = -100.0;
float lastHumidity = -100.0;
float lastMoisture = -100.0;
bool lastPumpStatus = false;
String clientId;
String sub_switchTopic;
String sub_soilTopic;
String sub_alarmTopic;
String sub_enabledAlarmTopic;
String pub_pumpTopic;
String pub_sensorTopic;
String pub_alarmTopic;

unsigned long lastSensorMillis = 0;
const unsigned long sensorInterval = 5000; // baca sensor tiap 5 detik

float currentTemperature = 0;
float currentHumidity = 0;
float currentMoisturePercent = 0;

unsigned long alarmStartMillis = 0;
const unsigned long alarmRunDuration = 30000; // auto off dalam 30 detik

unsigned long lastButtonRead = 0;
const unsigned long buttonInterval = 1000; // button device diread tiap 1s
static int lastBtnState = 1;
bool manualOverride = false;
bool switchOn = false;
unsigned long overrideUntil = 0;

int btn = 1;

// ===== ENUM CONTROL SOURCE =====
enum ControlBy
{
  DEVICE = 1, // tombol langsung di device
  SWITCH = 2, // HP / FE (via MQTT)
  SOIL = 3,   // soil min/max
  ALARM = 4   // alarm
};

ControlBy controlBy = DEVICE; // default: device

// ================== ENUM ALARM ==================
enum AlarmAction
{
  ADD_ALARM = 1,
  UPDATE_ALARM = 2,
  DELETE_ALARM = 3
};

struct Alarm
{
  String id;
  String time;               // format "HH:MM"
  int durationOn; // menit
  int repeatType; // 1=once, 2=daily, 3=weekly
  int repeatDays;    // bitmask (0–127) untuk weekly
};

std::vector<Alarm> alarms;

Preferences preferences;

unsigned long pumpAlarmUntil = 0;

enum RepeatType
{
  ONCE = 1,
  DAILY = 2,
  WEEKLY = 3
};

enum ConnectionState
{
  DISCONNECTED,
  UNSTABLE,
  STABLE
};

ConnectionState connectionState = DISCONNECTED;

unsigned long lastMqttReconnectAttempt = 0;
#define MAX_RETRY 5

void saveAlarmsToStorage()
{
  JsonDocument doc;
  JsonArray arr = doc.to<JsonArray>();

  for (const auto &a : alarms)
  {
    JsonObject obj = arr.createNestedObject();
    obj["id"] = a.id;
    obj["time"] = a.time;
    obj["duration_on"] = a.durationOn;
    obj["repeat_type"] = a.repeatType;
  }

  String jsonStr;
  serializeJson(doc, jsonStr);

  preferences.begin("hydros", false);
  preferences.putString("alarms", jsonStr);
  preferences.end();

  Serial.println("💾 Alarms saved to storage.");
}

void loadAlarmsFromStorage()
{
  preferences.begin("hydros", true);
  String jsonStr = preferences.getString("alarms", "[]");
  preferences.end();

  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, jsonStr);
  if (error)
  {
    Serial.printf("⚠️ Failed to parse stored alarms: %s\n", error.c_str());
    return;
  }

  alarms.clear();
  for (JsonObject obj : doc.as<JsonArray>())
  {
    Alarm a;
    a.id = obj["id"].as<String>();
    a.time = obj["time"].as<String>();
    a.durationOn = obj["duration_on"].as<int>();
    a.repeatType = obj["repeat_type"].as<int>();
    alarms.push_back(a);
  }

  Serial.printf("📂 Loaded %d alarms from storage.\n", alarms.size());
}

void addOrUpdateAlarm(String id, String time, int durationOn, int repeatType)
{
  for (auto &a : alarms)
  {
    if (a.id == id)
    {
      a.time = time;
      a.durationOn = durationOn;
      a.repeatType = repeatType;
      Serial.println("Alarm updated in local list.");
      saveAlarmsToStorage();
      return;
    }
  }

  // jika belum ada → tambah
  Alarm newAlarm = {id, time, durationOn, repeatType};
  alarms.push_back(newAlarm);
  Serial.println("Alarm added to local list.");
  saveAlarmsToStorage();
}

void publishDeleteAlarm(const String &id)
{
  JsonDocument doc;

  doc["alarm_id"] = id;

  char payload[256];
  serializeJson(doc, payload, sizeof(payload));
  
  pubSubClient.publish(pub_alarmTopic.c_str(), payload);

  Serial.print("Published alarm delete: ");
  Serial.println(payload);
  Serial.println("\n============================\n");
}

void printAlarms()
{
  Serial.println("📋 Current Alarm List:");
  for (const auto &a : alarms)
  {
    Serial.printf(" - ID: %s | Time: %s | Duration: %d | RepeatType: %d\n",
                  a.id.c_str(), a.time.c_str(), a.durationOn, a.repeatType);
  }
  if (alarms.empty())
  {
    Serial.println(" (empty)");
  }
}

void deleteAlarm(const String &id)
{
  
  for (auto it = alarms.begin(); it != alarms.end(); ++it)
  {
    if (it->id == id)
    {
      alarms.erase(it);
      Serial.println("🗑️ Alarm deleted from local list.");

      saveAlarmsToStorage();
      printAlarms();
      return;
    }
  }
  Serial.println("⚠️ Alarm not found in local list.");
}

void handleSubscribeAllDataMqtt(char *topic, byte *payload, unsigned int length)
{
  Serial.print("Callback MQTT: [");
  Serial.print(topic);
  Serial.print("] ");

  // Konversi payload ke string
  String msg;
  for (unsigned int i = 0; i < length; i++)
  {
    msg += (char)payload[i];
  }
  Serial.println(msg);

  // JSON parsing
  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, msg);
  if (error)
  {
    Serial.print("deserializeJson() gagal: ");
    Serial.println(error.c_str());
    return;
  }

  // =========================
  // SWITCH CONTROL (via HP/FE)
  // =========================
  if (strcmp(topic, sub_switchTopic.c_str()) == 0)
  {
    int status = doc["status"].as<int>();

    if (status == 1)
    {
      Serial.println("\n--- Pompa ON by SWITCH ---\n");
      ledGreenOn = true;
      ledRedOn = false;
      controlBy = SWITCH;
      manualOverride = true;
      switchOn = true;
      btn = 0; // sinkronkan ke tombol
      Serial.println("\n============================\n");
    }
    else if (status == 2)
    {
      Serial.println("\n--- Pompa OFF by SWITCH ---\n");
      ledGreenOn = false;
      ledRedOn = true;
      controlBy = SWITCH;
      btn = 1; // sinkronkan ke tombol
      switchOn = false;
      manualOverride = true;

      // kalau soil masih kering, jangan langsung nyala lagi → kasih delay
      overrideUntil = millis() + 10000; // 10 s
      Serial.println("Manual OFF by SWITCH, override soil selama 10s");
      Serial.println("\n============================\n");
    }
  }

  // =========================
  // SOIL CONFIG UPDATE
  // =========================
  else if (strcmp(topic, sub_soilTopic.c_str()) == 0)
  {
    soilStart = doc["soil_min"].as<float>();
    soilEnd = doc["soil_max"].as<float>();

    Serial.print("Soil Min set ke: ");
    Serial.println(soilStart, 2);
    Serial.print("Soil Max set ke: ");
    Serial.println(soilEnd, 2);
    Serial.println("\n============================\n");
  }


  // =========================
  // ALARM
  // =========================
  else if (strcmp(topic, sub_alarmTopic.c_str()) == 0) {
    int action = doc["action"].as<int>(); // add, update, delete
    String alarmId = doc["alarm_id"].as<String>();

    if (action == ADD_ALARM)
    { // add
      String scheduleTime = doc["schedule_time"].as<String>();
      int durationOn = doc["duration_on"].as<int>();
      int repeatType = doc["repeat_type"].as<int>();

      Serial.println("\n--- ADD ALARM ---");
      Serial.printf("AlarmID: %s\n", alarmId);
      Serial.printf("Time: %s | Duration: %d min\n", scheduleTime.c_str(), durationOn);
      Serial.printf("RepeatType: %d\n", repeatType);

      // simpan alarm ke struktur data lokal (array / vector)
      addOrUpdateAlarm(alarmId, scheduleTime, durationOn, repeatType);
    }

    else if (action == UPDATE_ALARM)
    { // update
      String scheduleTime = doc["schedule_time"].as<String>();
      int durationOn = doc["duration_on"].as<int>();
      int repeatType = doc["repeat_type"].as<int>();

      Serial.println("\n--- UPDATE ALARM ---");
      Serial.printf("AlarmID: %s\n", alarmId);
      Serial.printf("Time: %s | Duration: %d min\n", scheduleTime.c_str(), durationOn);
      Serial.printf("RepeatType: %d\n", repeatType);

      // update alarm di struktur lokal
      addOrUpdateAlarm(alarmId, scheduleTime, durationOn, repeatType);
    }

    else if (action == DELETE_ALARM)
    { // delete
      Serial.println("\n--- DELETE ALARM ---");
      Serial.printf("AlarmID: %s\n", alarmId);

      // hapus alarm dari struktur data lokal
      deleteAlarm(alarmId);
    }

    Serial.println("\n============================\n");
    printAlarms();
  }

  else if (strcmp(topic, sub_enabledAlarmTopic.c_str()) == 0)
  {
    Serial.println("TESTESTES");
    bool action = doc["is_enabled"].as<bool>();
    String alarmId = doc["alarm_id"].as<String>();

    if (action == false){
      deleteAlarm(alarmId);
    }

    Serial.printf("Delete alarm id: %s\n", alarmId);
    Serial.println("\n============================\n");
  }
}

void publishPumpStatusWithControl(int controlBy, bool pumpIsOn)
{
  JsonDocument doc;

  doc["device_id"] = device_id;
  doc["pump_status"] = pumpIsOn ? 1 : 2;     // 1 = ON, 2 = OFF
  doc["type"] = 2;                           // misalnya: 2 untuk pump status
  doc["control_by"] = (int)controlBy;        // 1=Device, 2=Switch, 3=Soil, 4=Alarm
  doc["time"] = now.unixtime() - (7 * 3600); // pakai RTC/epoch timestamp : kurangi 7 jam biar sinkron dg be
  doc["soil_value"] = currentMoisturePercent;

  char payload[256];
  serializeJson(doc, payload, sizeof(payload));

  pubSubClient.publish(pub_pumpTopic.c_str(), payload);

  Serial.print("Published pump status: ");
  Serial.println(payload);
  Serial.println("\n============================\n");
}

void publishSensorData(float temperature, float humidity, float soilMoisture)
{
  JsonDocument doc;

  doc["device_id"] = device_id;
  doc["temperature"] = temperature;
  doc["humidity"] = humidity;
  doc["soil_moisture"] = soilMoisture;
  doc["type"] = 1;

  char payload[256];
  serializeJson(doc, payload, sizeof(payload));

  pubSubClient.publish(pub_sensorTopic.c_str(), payload);

  Serial.print("\nPublished sensor: ");
  Serial.println(payload);
}

void sendConnectionStatus(bool wifiConnected, bool mqttConnected)
{
  ConnectionState newState;

  if (!wifiConnected && !mqttConnected)
    newState = DISCONNECTED;
  else if (wifiConnected && !mqttConnected)
    newState = UNSTABLE;
  else
    newState = STABLE;

  // hanya kirim kalau status berubah
  if (newState != connectionState)
  {
    connectionState = newState;

    String statusStr;
    switch (connectionState)
    {
    case DISCONNECTED:
      statusStr = "disconnected";
      break;
    case UNSTABLE:
      statusStr = "unstable";
      break;
    case STABLE:
      statusStr = "stable";
      break;
    }

    String willTopic = "from-esp/" + device_id + "/status-device";

    JsonDocument doc;
    doc["type"] = 3;
    doc["device_id"] = device_id;
    doc["status"] = statusStr;

    String payload;
    serializeJson(doc, payload);
    pubSubClient.publish(willTopic.c_str(), payload.c_str(), true);

    Serial.printf("Connection State Changed → %s\n", statusStr.c_str());
  }
}

void reconnectMQTT()
{
  if (pubSubClient.connected())
    return;

  unsigned long now = millis();
  if (now - lastMqttReconnectAttempt < 2000)
  {
    return;
  }
  lastMqttReconnectAttempt = now;
  Serial.print("Attempting MQTT connection... ");

  // LWT setup
  String willTopic = "from-esp/" + device_id + "/status-device";
  JsonDocument willDoc;
  willDoc["type"] = 3;
  willDoc["device_id"] = device_id;
  willDoc["status"] = "disconnected";

  String willPayload;
  serializeJson(willDoc, willPayload);

  pubSubClient.setKeepAlive(30); // 30 detik

  // Set LWT via connect() parameters
  if (pubSubClient.connect(clientId.c_str(), willTopic.c_str(), 1, true, willPayload.c_str()))
  {
    Serial.println("connected ✅");
    Serial.println("MQTT connected, subscribing to topics...");
    // Kirim status stable
    sendConnectionStatus(true, true);

    pubSubClient.subscribe(sub_switchTopic.c_str());
    pubSubClient.subscribe(sub_soilTopic.c_str());
    pubSubClient.subscribe(sub_alarmTopic.c_str());
    pubSubClient.subscribe(sub_enabledAlarmTopic.c_str());
  }
  else
  {
    Serial.print("failed, rc=");
    Serial.print(pubSubClient.state());
    Serial.println(" → retrying...");
    sendConnectionStatus(true, false);
  }
}

bool saveWiFiList(JsonArray wifiArray)
{
  File file = SPIFFS.open(wifiFile, FILE_WRITE);
  if (!file)
  {
    Serial.println("❌ Failed to open WiFi file for writing");
    return false;
  }

  serializeJson(wifiArray, file);
  file.close();
  Serial.println("✅ WiFi list saved");
  return true;
}

JsonArray readWiFiList(DynamicJsonDocument &doc)
{
  if (!SPIFFS.exists(wifiFile))
  {
    Serial.println("⚠️ WiFi list not found, creating new file");
    File f = SPIFFS.open(wifiFile, FILE_WRITE);
    f.print("[]");
    f.close();
  }

  File file = SPIFFS.open(wifiFile, FILE_READ);
  if (!file)
  {
    Serial.println("❌ Failed to open WiFi file");
    return doc.to<JsonArray>();
  }

  DeserializationError error = deserializeJson(doc, file);
  file.close();

  if (error)
  {
    Serial.println("❌ Failed to parse WiFi file");
    return doc.to<JsonArray>();
  }

  return doc.as<JsonArray>();
}

bool isSSIDStored(JsonArray wifiArray, String ssid)
{
  for (JsonObject obj : wifiArray)
  {
    if (obj["ssid"].as<String>() == ssid)
      return true;
  }
  return false;
}

void addWiFiToList(String ssid, String pass)
{
  DynamicJsonDocument doc(1024);
  JsonArray wifiArray = readWiFiList(doc);

  if (!isSSIDStored(wifiArray, ssid))
  {
    JsonObject newWifi = wifiArray.createNestedObject();
    newWifi["ssid"] = ssid;
    newWifi["pass"] = pass;
    saveWiFiList(wifiArray);
    Serial.printf("✅ Added new WiFi: %s\n", ssid.c_str());
  }
  else
  {
    Serial.printf("ℹ️ WiFi %s already stored\n", ssid.c_str());
  }
}

// ======================================
// ==== CONNECTING TO SAVED NETWORKS ====
// ======================================

bool tryConnectToSavedWiFi()
{
  DynamicJsonDocument doc(1024);
  JsonArray wifiArray = readWiFiList(doc);

  for (JsonObject obj : wifiArray)
  {
    String ssid = obj["ssid"].as<String>();
    String pass = obj["pass"].as<String>();

    Serial.printf("🔍 Trying WiFi: %s\n", ssid.c_str());
    WiFi.begin(ssid.c_str(), pass.c_str());

    unsigned long startAttemptTime = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < 7000)
    {
      delay(500);
      Serial.print(".");
    }

    if (WiFi.status() == WL_CONNECTED)
    {
      Serial.printf("\n✅ Connected to %s\n", ssid.c_str());
      lcd.clear();
      lcd.setCursor(2, 0);
      lcd.print("Successfully");
      lcd.setCursor(1, 1);
      lcd.print("Connected Wifi");

      delay(3000);

      // Sinkronisasi waktu dari NTP
      configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
      struct tm timeinfo;
      if (!getLocalTime(&timeinfo))
      {
        Serial.println("Gagal mendapatkan waktu dari NTP.");
        return false;
      }

      // Setel waktu ke RTC
      getLocalTime(&timeinfo);
      rtc.adjust(DateTime(timeinfo.tm_year + 1900, timeinfo.tm_mon + 1, timeinfo.tm_mday, timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec));
      now = rtc.now();
      Serial.printf("Waktu RTC   : %04d-%02d-%02d %02d:%02d:%02d\n",
                    now.year(), now.month(), now.day(),
                    now.hour(), now.minute(), now.second());

      // MQTT
      pubSubClient.setServer(mqtt_broker, mqtt_port);
      pubSubClient.setCallback(handleSubscribeAllDataMqtt);

      return true;
    }
    else
    {
      Serial.println("\n❌ Failed, trying next...");
    }
  }

  return false;
}

String getDeviceID()
{
  uint64_t chipid = ESP.getEfuseMac(); // chip ID unik ESP32
  char id[20];
  sprintf(id, "%04X%08X",
          (uint16_t)(chipid >> 32), (uint32_t)chipid);
  return String(id);
}

// =================== WIFI CONFIG ===================
void uiConfigureWifi()
{
  // Custom Web UI
  std::vector<const char *> menuItems = {"wifi", "info", "exit"};
  wm.setMenu(menuItems);
  wm.setClass("invert");
  wm.setTitle("HYDROS");
  wm.setCustomHeadElement("<style>h2{color: gray;}</style>");
}

void connectWifi()
{
  if (WiFi.status() != WL_CONNECTED)
  {
    unsigned long now = millis();
    if (now - lastReconnectAttempt > 1000)
    {
      lastReconnectAttempt = now;
      countReconnect++;

      Serial.println("🔁 Reconnecting WiFi...");
      WiFi.reconnect();

      if (WiFi.status() == WL_CONNECTED)
      {
        Serial.println("✅ Reconnected");
        countReconnect = 0;
      }

      else if (countReconnect >= MAX_RETRY)
      {
        Serial.println("⚠️ WiFi Lost, open portal...");
        wm.startConfigPortal("HYDROS_AP", "password");
        countReconnect = 0;
      }
    }
  }

  sendConnectionStatus(WiFi.status() == WL_CONNECTED, pubSubClient.connected());
}

void readSensors(){
  float humidity = dht.readHumidity();
  float moisture = analogRead(soil);
  float temperature = dht.readTemperature();

  float moisturePercent = map(moisture, 1800, 3400, 100, 0);
  moisturePercent = constrain(moisturePercent, 0, 100);

  currentHumidity = humidity;
  currentTemperature = temperature;
  currentMoisturePercent = moisturePercent;
}

void lcdDisplay(){
  if (millis() - previousDisplayMillis >= displayInterval)
  {
    switch (currentState)
    {
    case DisplayState::INITIAL:
      lcd.clear();
      lcd.setCursor(5, 0);
      lcd.print("Smart");
      lcd.setCursor(3, 1);
      lcd.print("Irrigation");
      currentState = DisplayState::HUMIDITY_TEMP;
      break;

    case DisplayState::HUMIDITY_TEMP:
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Humidity: " + String(currentHumidity, 1) + " %");
      lcd.setCursor(0, 1);
      lcd.print("Temperature: " + String(currentTemperature, 0) + "C");
      currentState = DisplayState::SOIL_MOISTURE;
      break;

    case DisplayState::SOIL_MOISTURE:
      lcd.clear();
      lcd.setCursor(2, 0);
      lcd.print("Soil: " + String(currentMoisturePercent) + " %");
      currentState = DisplayState::TIMESTAMP;
      break;

    case DisplayState::TIMESTAMP:
      lcd.clear();
      char buffer[17]; // Buffer untuk string format tanggal
      sprintf(buffer, "%02d/%02d/%d", now.day(), now.month(), now.year());
      lcd.setCursor(3, 0);
      lcd.print(buffer);

      sprintf(buffer, "%02d:%02d:%02d", now.hour(), now.minute(), now.second());
      lcd.setCursor(4, 1);
      lcd.print(buffer);

      currentState = DisplayState::INITIAL;
      break;
    }

    previousDisplayMillis = millis();
  }
}

String formatTime(int hour, int minute)
{
  char buf[6];
  sprintf(buf, "%02d:%02d", hour, minute);
  return String(buf);
}

bool shouldTriggerAlarm(const Alarm &a, int currentDay)
{
  switch (a.repeatType)
  {
  case RepeatType::ONCE:
    return true;

  case RepeatType::DAILY:
    return true;

  case RepeatType::WEEKLY:
    // bit 0 = Minggu, bit 1 = Senin, dst.
    return (a.repeatDays & (1 << currentDay));
  default:
    return false;
  }
}

void setup()
{
  
  Serial.begin(115200);

  lcd.init();
  lcd.backlight();
  Wire.begin();

  // rtc
  if (!rtc.begin())
  {
    Serial.println("Couldn't find RTC");
  }
  if (rtc.lostPower())
  {
    Serial.println("RTC lost power, let's set the time!");
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  device_id = getDeviceID();
  clientId = "ESP32HydrosClient-" + device_id;
  sub_switchTopic = "from-app/" + device_id + "/handle-pump/from-switch";
  sub_soilTopic = "from-app/" + device_id + "/handle-pump/from-soil";
  sub_alarmTopic = "from-app/" + device_id + "/handle-pump/from-alarm";
  sub_enabledAlarmTopic = "from-app/" + device_id + "/control-enabled-alarm";
  pub_pumpTopic = "from-esp/" + device_id + "/pump-status";
  pub_alarmTopic = "from-esp/" + device_id + "/delete-alarm";

  Serial.print("Device ID: ");
  Serial.println(device_id);

  Serial.print("\nClient ID = ");
  Serial.println(clientId);

  // SPIFFS
  if (!SPIFFS.begin(true))
  {
    Serial.println("Failed to mount SPIFFS");
  }

  // LCD - wifi
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Connecting WiFi");
  lcd.setCursor(0, 1);
  lcd.print("Please wait...");

  uiConfigureWifi();

  if (!tryConnectToSavedWiFi())
  {
    Serial.println("⚠️ No known WiFi found, opening portal...");

    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Open Portal...");
    lcd.setCursor(4, 1);
    lcd.print("HYDROS_AP");

    wm.setConfigPortalTimeout(180); // 3 menit timeout
    bool portal = wm.startConfigPortal("HYDROS_AP", "password");

    if (portal)
    {
      String ssid = WiFi.SSID();
      String pass = WiFi.psk();
      addWiFiToList(ssid, pass);
    }
    else
    {
      Serial.println("❌ Failed, restarting...");
      delay(2000);
      ESP.restart();
    }
  }
  else
  {
    Serial.printf("✅ Connected to %s\n", WiFi.SSID().c_str());
  }

  pinMode(soil, INPUT);
  pinMode(relay, OUTPUT);
  pinMode(ledRed, OUTPUT);
  pinMode(ledGreen, OUTPUT);
  pinMode(button, INPUT_PULLUP);

  digitalWrite(relay, relayOFF);
  digitalWrite(ledRed, HIGH);
  digitalWrite(ledGreen, LOW);

  // ALARM
  Serial.println("\n============================\n");
  loadAlarmsFromStorage();
  // deleteAlarm("7");
  // deleteAlarm("9");

  printAlarms();
}

void loop()
{
  now = rtc.now();
  String currentTime = formatTime(now.hour(), now.minute());
  int currentDay = now.dayOfTheWeek(); // 0=Sunday, 1=Monday, ...

  // Connect WiFi
  connectWifi();

  // MQTT
  if (!pubSubClient.connected())
  {
    reconnectMQTT();
  }
  else
  {
    pubSubClient.loop();
  }

  int btn = digitalRead(button);
  mean = (soilStart + soilEnd) / 2.0;

  if (millis() - lastSensorMillis >= sensorInterval)
  {
    readSensors();

    lastSensorMillis = millis();
  }

  // LCD
  lcdDisplay();

  // =======================
  // PUMP CONTROL LOGIC
  // =======================

  // --- DEVICE BUTTON ---
  if (millis() - lastButtonRead >= buttonInterval)
  {
    lastButtonRead = millis();

    btn = digitalRead(button);

    // --- DEVICE BUTTON ---
    if (btn != lastBtnState) {
      if (btn == 0)
      { // ON
        if (!pumpIsOn)
        {
          Serial.println("Pompa ON by DEVICE");
          controlBy = DEVICE;
          ledGreenOn = true;
          ledRedOn = false;
          pumpIsOn = true;
          manualOverride = true;
          switchOn = true;
        }
      }
      else if (btn == 1)
      { // OFF
        if (pumpIsOn)
        {
          Serial.println("Pompa OFF by DEVICE");
          ledGreenOn = false;
          ledRedOn = true;
          pumpIsOn = false;
          manualOverride = true;
          controlBy = DEVICE;
          if (switchOn) {
            switchOn = false;
          }

          // kasih delay kalau lagi override soil
          overrideUntil = millis() + 10000;
          Serial.println("Manual OFF by DEVICE, override soil selama 10s");
        }
      }
      lastBtnState = btn;
    }
  }

  // --- SOIL AUTO --- 
  if (!manualOverride) {
    if (currentMoisturePercent < soilStart && !pumpIsOn) // nyala kalo soil dibawah soilStart
    { 
      Serial.println("Pompa ON by SOIL"); 
      controlBy = SOIL; 
      ledGreenOn = true; 
      ledRedOn = false; 
    } 
    
    // auto mati kalo udah nyala dan soil diatas mean
    else if (pumpIsOn && controlBy == SOIL && currentMoisturePercent >= mean) 
    {
      Serial.println("Pompa OFF by SOIL");
      ledGreenOn = false;
      ledRedOn = true; 
    }
  }

  // --- RESET override setelah timeout ---
  if (manualOverride && millis() > overrideUntil)
  {
    Serial.println("Override timeout habis, soil aktif lagi");
    manualOverride = false;
  }

  // --- ALARM AUTO ---
  for (size_t i = 0; i < alarms.size(); i++)
  {
    Alarm &a = alarms[i];

    if (a.time == currentTime)
    {
      if (shouldTriggerAlarm(a, currentDay))
      {

        // Jika pompa belum ON, baru boleh start
        if (!pumpIsOn)
        {
          controlBy = ALARM;
          ledGreenOn = true;
          ledRedOn = false;
          pumpAlarmUntil = millis() + (a.durationOn * 60UL * 1000UL);
          Serial.printf("⏰ Alarm triggered: %s (%d min)\n", a.time.c_str(), a.durationOn);

          // Hapus alarm jika tipe-nya once
          if (a.repeatType == ONCE)
          {
            Serial.printf("ID ALARM DELETE: %s\n", a.id);
            publishDeleteAlarm(a.id);
            deleteAlarm(a.id);
          }
        }
        else
        {
          // Pompa sedang ON → alarm di-skip 
          Serial.println("Pompa lagi nyala, skip alarm");
        }
      }
    }
  }

  // auto mati kalo udah nyala dan soil diatas mean
  if (pumpIsOn && controlBy == ALARM && (millis() >= pumpAlarmUntil))
  {
    Serial.println("Pompa OFF by ALARM");
    ledGreenOn = false;
    ledRedOn = true;
  }
  // if (alarmTriggered) {
  //   ledGreenOn = true;
  //   ledRedOn = false;
  //   if (!pumpIsOn) {
  //     controlBy = ALARM;  // Alarm
  //     alarmStartMillis = millis();
  //   }
  // }
  // if (pumpIsOn && controlBy == ALARM && (millis() - alarmStartMillis >= alarmRunDuration)) {
  //   ledGreenOn = false;
  //   ledRedOn = true;
  // }

  // =======================
  // RELAY & LED UPDATE
  // =======================
  if (ledRedOn)
  {
    digitalWrite(relay, relayOFF);
    digitalWrite(ledRed, HIGH);
    digitalWrite(ledGreen, LOW);
    pumpIsOn = false;
  }
  if (ledGreenOn)
  {
    digitalWrite(relay, relayON);
    digitalWrite(ledRed, LOW);
    digitalWrite(ledGreen, HIGH);
    pumpIsOn = true;
  }

  // =======================
  // PUBLISH TO MQTT
  // =======================
  if (fabs(currentTemperature - lastTemperature) >= 1 ||
      fabs(currentHumidity - lastHumidity) >= 1 ||
      fabs(currentMoisturePercent - lastMoisture) >= 1)
  {
    publishSensorData(currentTemperature, currentHumidity, currentMoisturePercent);
    lastTemperature = currentTemperature;
    lastHumidity = currentHumidity;
    lastMoisture = currentMoisturePercent;
  }

  if (pumpIsOn != lastPumpStatus)
  {
    publishPumpStatusWithControl(controlBy, pumpIsOn);
    lastPumpStatus = pumpIsOn;
  }
}
