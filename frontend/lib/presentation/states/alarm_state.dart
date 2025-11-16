class AlarmState {
  final List<Map<String, dynamic>> listAlarm;
  final String nextAlarmStr;

  const AlarmState({
    required this.listAlarm,
    required this.nextAlarmStr,
  });

  AlarmState copyWith({
    List<Map<String, dynamic>>? listAlarm,
    String? nextAlarmStr,
  }) {
    return AlarmState(
      listAlarm: listAlarm ?? this.listAlarm,
      nextAlarmStr: nextAlarmStr ?? this.nextAlarmStr,
    );
  }
}