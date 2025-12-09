import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/device_provider.dart';
import 'package:frontend/presentation/states/device_state.dart';
import 'package:frontend/presentation/widgets/global/app_bar.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/home/pie_chart.dart';
import 'package:frontend/presentation/widgets/home/status_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/validator.dart';
import '../providers/injection.dart';
import '../providers/websocket/sensor_provider.dart';
import '../widgets/global/loading.dart';
import '../widgets/global/text_form_field.dart';
import '../widgets/home/ai/ai_glow_loader.dart';
import '../widgets/home/ai/ai_typing_text.dart';
import '../widgets/home/button_ai.dart';
import '../widgets/home/google_place.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  Future<void> _logSecureStorage() async {
    final token = await SecureStorage.getAccessToken();
    final userId = await SecureStorage.getUserId();
    final deviceId = await SecureStorage.getDeviceId();
    final pairedAt = await SecureStorage.getPairedAt();

    logger.i('🔐 Access Token: $token');
    logger.i('👤 User ID: $userId');
    logger.i('📱 Device ID: $deviceId');
    logger.i('⏱️ Paired At: $pairedAt');
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  String location = '-';
  String weather = '-';
  String selectedPlace = '';
  String selectedLat = '';
  String selectedLng = '';
  String plantName = '-';
  double plantingWeeks = 1;
  String lastWatered = '--:--:--';
  int pumpUsage = 0;

  String locationKey = '';

  int currentWeek = 0;
  int totalWeek = 1;

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isLoadingInit = true;

  late String? deviceId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mq = MediaQuery.of(context);

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor:
              mq.orientation == Orientation.portrait
                  ? AppColors.primary
                  : AppColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      );
    });

    Future.microtask(() async {
      try {
        deviceId = await SecureStorage.getDeviceId();
        final hasPlant = await SecureStorage.getHasPlant();

        if (!mounted) return;

        if (deviceId == null) {
          setState(() => isLoadingInit = false);
          return;
        }

        if (hasPlant) {
          ref.read(deviceProvider.notifier).setPairedWithPlant(deviceId!);

          await _loadPlantAssistant(deviceId!);
        } else {
          ref.read(deviceProvider.notifier).setPairedNoPlant(deviceId!);
        }
      } catch (e) {
        debugPrint("INIT ERROR: $e");
      } finally {
        if (mounted) {
          setState(() => isLoadingInit = false);
        }
      }
    });
  }


  Future<void> _loadPlantAssistant(String deviceId) async {
    try {
      final homeController = ref.read(homeControllerProvider);
      final data = await homeController.getPlantAssistantController(deviceId);
      setState(() {
        location = data['location'];
        weather = data['weather'];
        currentWeek = data['progress_now'];
        totalWeek = data['progress_plan'];
        plantName = data['plant_name'];
        lastWatered = data['last_watered'];
        pumpUsage = data['pump_usage'];
        nameController.text = data['plant_name'];
        locationController.text = data['location'];
        plantingWeeks = data['progress_plan'].toDouble();
        selectedLat = data['lat'];
        selectedLng = data['long'];
        selectedPlace = data['location'];
        locationKey = Uuid().v4();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleAddPlant() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.pop();
    setState(() => isLoading = true);

    final deviceId = await SecureStorage.getDeviceId();
    final homeController = ref.read(homeControllerProvider);

    try {
      final msg = await homeController.addPlantController(
        deviceId,
        nameController.text,
        plantingWeeks.toInt().toString(),
        selectedLng,
        selectedLat,
        selectedPlace,
      );

      setState(() {
        plantName = nameController.text;
      });

      ref.read(deviceProvider.notifier).setPairedWithPlant(deviceId!);

      _loadPlantAssistant(deviceId);

      SecureStorage.saveHasPlant(true);

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDeletePlant() async {
    setState(() => isLoading = true);

    final deviceId = await SecureStorage.getDeviceId();

    setState(() {
      plantName = '';
      nameController.text = '';
      plantingWeeks = 1;
      selectedLat = '';
      selectedLng = '';
      selectedPlace = '';
      lastWatered = '--:--:--';
      location = '-';
      weather = '-';
      currentWeek = 0;
      totalWeek = 1;
      pumpUsage = 0;
      locationKey = Uuid().v4();
      locationController = TextEditingController();
    });

    ref.read(deviceProvider.notifier).setPairedNoPlant(deviceId!);

    SecureStorage.saveHasPlant(false);

    if (!mounted) return;

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plant successfully deleted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAddPlantBottomSheet(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacingSize.l,
              right: AppSpacingSize.l,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Plant',
                            style: TextStyle(
                              fontWeight: AppFontWeight.semiBold,
                              fontSize: AppFontSize.l,
                            ),
                          ),
                          SizedBox(height: AppSpacingSize.m),

                          /// Plant Name
                          TextFormFieldWidget(
                            controller: nameController,
                            label: 'Plant Name*',
                            validator: AppValidator.plantNameRequired,
                          ),
                          SizedBox(height: AppSpacingSize.xl),

                          /// Planting Weeks
                          Text(
                            'Planting Duration Plan (Week) *',
                            style: TextStyle(
                              fontSize: AppFontSize.s,
                              fontWeight: AppFontWeight.medium,
                            ),
                          ),
                          Slider(
                            value: plantingWeeks,
                            min: 1,
                            max: 60,
                            divisions: 60,
                            label: plantingWeeks.round().toString(),
                            activeColor: AppColors.orange,
                            onChanged: (v) {
                              final rounded = v.round().toDouble();
                              setModalState(() => plantingWeeks = rounded);
                            },
                          ),

                          SizedBox(height: AppSpacingSize.m),

                          /// Location Widget (Sudah support lat/lng)
                          LocationAutoCompleteWidget(
                            key: ValueKey(locationKey),
                            controller: locationController,
                            validator: AppValidator.locationRequired,
                            onLatLngSelected: (lat, lng) {
                              setModalState(() {
                                selectedLat = lat;
                                selectedLng = lng;
                              });
                            },
                            onPlaceSelected: (p) {
                              setModalState(() {
                                selectedPlace = p.description!;
                              });
                            },
                          ),

                          SizedBox(height: AppSpacingSize.xl),
                        ],
                      ),
                    ),
                  ),
                ),

                /// Save Button
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    text: 'Save',
                    onPressed: () => _handleAddPlant(),
                  ),
                ),

                SizedBox(height: AppSpacingSize.m),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmDeletePlant() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Plant",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete plant? This action can't be undo.",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                context.pop();
                _handleDeletePlant();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleEditPlant() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.pop();
    setState(() => isLoading = true);

    final deviceId = await SecureStorage.getDeviceId();
    final homeController = ref.read(homeControllerProvider);

    try {
      final msg = await homeController.editPlantController(
        deviceId,
        nameController.text,
        plantingWeeks.toInt().toString(),
        selectedLng,
        selectedLat,
        selectedPlace,
      );

      setState(() {
        plantName = nameController.text;
      });

      ref.read(deviceProvider.notifier).setPairedWithPlant(deviceId!);

      _loadPlantAssistant(deviceId);

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEditPlantBottomSheet(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacingSize.l,
              right: AppSpacingSize.l,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Plant',
                            style: TextStyle(
                              fontWeight: AppFontWeight.semiBold,
                              fontSize: AppFontSize.l,
                            ),
                          ),
                          SizedBox(height: AppSpacingSize.m),

                          /// Plant Name
                          TextFormFieldWidget(
                            controller: nameController,
                            label: 'Plant Name*',
                            validator: AppValidator.plantNameRequired,
                          ),
                          SizedBox(height: AppSpacingSize.xl),

                          /// Planting Weeks
                          Text(
                            'Planting Duration Plan (Week) *',
                            style: TextStyle(
                              fontSize: AppFontSize.s,
                              fontWeight: AppFontWeight.medium,
                            ),
                          ),
                          Slider(
                            value: plantingWeeks,
                            min: 1,
                            max: 60,
                            divisions: 60,
                            label: plantingWeeks.round().toString(),
                            activeColor: AppColors.orange,
                            onChanged: (v) {
                              final rounded = v.round().toDouble();
                              setModalState(() => plantingWeeks = rounded);
                            },
                          ),

                          SizedBox(height: AppSpacingSize.m),

                          /// Location Widget (Sudah support lat/lng)
                          LocationAutoCompleteWidget(
                            controller: locationController,
                            validator: AppValidator.locationRequired,
                            onLatLngSelected: (lat, lng) {
                              setModalState(() {
                                selectedLat = lat;
                                selectedLng = lng;
                              });
                            },
                            onPlaceSelected: (p) {
                              setModalState(() {
                                selectedPlace = p.description!;
                              });
                            },
                          ),

                          SizedBox(height: AppSpacingSize.xl),
                        ],
                      ),
                    ),
                  ),
                ),

                /// Save Button
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    text: 'Save Change',
                    onPressed: () => _handleEditPlant(),
                  ),
                ),

                SizedBox(height: AppSpacingSize.m),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUI(
    DevicePairState state,
    BuildContext context,
    double temperature,
    double humidity,
    double soil,
  ) {
    if (state is PairedNoPlant) {
      return Padding(
        padding: EdgeInsets.all(AppSpacingSize.l),
        child: Column(
          spacing: AppSpacingSize.l,
          children: [
            Text(
              'No Plant Added Yet',
              style: TextStyle(
                fontSize: AppFontSize.l,
                fontWeight: AppFontWeight.medium,
              ),
            ),
            Image.asset(
              'lib/assets/images/no_plant_add.png',
              width: 126,
              height: 120,
            ),
            ButtonWidget(
              text: "+ Add Plant",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.rl),
                    ),
                  ),
                  builder: (context) => _buildAddPlantBottomSheet(context, ref),
                );
              },
            ),
          ],
        ),
      );
    } else if (state is PairedWithPlant) {
      return Padding(
        padding: EdgeInsets.all(AppSpacingSize.l),
        child: Column(
          spacing: AppSpacingSize.l + 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: AppSpacingSize.xs,
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedPlant01),
                    Text(
                      (plantName.isEmpty) ? '' : plantName,
                      style: TextStyle(
                        fontSize: AppFontSize.m,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),

                // === Icon Edit & Delete ===
                Row(
                  spacing: 8,
                  children: [
                    // EDIT
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadius.rl),
                            ),
                          ),
                          builder:
                              (context) =>
                                  _buildEditPlantBottomSheet(context, ref),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gray, width: 0.7),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.gray,
                        ),
                      ),
                    ),

                    // DELETE
                    GestureDetector(
                      onTap: () {
                        _showConfirmDeletePlant();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.danger,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacingSize.xxs,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: AppSpacingSize.xs,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedWaterPump,
                          size: AppElementSize.sm,
                        ),
                        Text(
                          'Pump Usage',
                          style: TextStyle(fontSize: AppFontSize.s),
                        ),
                      ],
                    ),
                    Text(
                      '${pumpUsage}x',
                      style: TextStyle(
                        fontSize: AppFontSize.l + 6,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    Text('Today', style: TextStyle(fontSize: AppFontSize.s)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: AppSpacingSize.xxs,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: AppSpacingSize.xs,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedClock01,
                          size: AppElementSize.sm,
                        ),
                        Text(
                          'Last Watered',
                          style: TextStyle(fontSize: AppFontSize.s),
                        ),
                      ],
                    ),
                    Text(
                      lastWatered,
                      style: TextStyle(
                        fontSize: AppFontSize.l + 6,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              spacing: AppSpacingSize.xs + 2,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: AppSpacingSize.xs,
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedProgress04),
                    Text(
                      'Progress Overview',
                      style: TextStyle(
                        fontSize: AppFontSize.m,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.rl),
                  child: LinearProgressIndicator(
                    value: currentWeek / totalWeek,
                    minHeight: 8,
                    backgroundColor: AppColors.grayDivider,
                    valueColor: AlwaysStoppedAnimation(AppColors.orange),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: AppSpacingSize.xs,
                  children: [
                    Text(
                      'Week $currentWeek of $totalWeek',
                      style: TextStyle(fontSize: AppFontSize.s),
                    ),
                  ],
                ),
              ],
            ),
            ButtonAiWidget(
              text: 'Analyze',
              onPressed: () => _handleAnalyzeAI(temperature, humidity, soil),
              pngAsset: "lib/assets/images/gemini.png",
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showAiLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(AppSpacingSize.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [AiGlowLoader(), SizedBox(height: 24), AiTypingText()],
          ),
        );
      },
    );
  }

  Future<void> _handleAnalyzeAI(
    double temperature,
    double humidity,
    double soil,
  ) async {
    _showAiLoading();

    try {
      final homeController = ref.read(homeControllerProvider);

      final result = await homeController.getAiReportController(
        plantName,
        totalWeek, // progressPlan
        currentWeek, // progressNow
        selectedLng,
        selectedLat,
        temperature,
        soil,
        humidity,
        pumpUsage,
        lastWatered,
        DateTime.now().toIso8601String(),
      );

      if (!mounted) return;

      context.pop();
      _showResultBottomSheet(result, temperature, soil, humidity);
    } catch (e) {
      if (!mounted) return;

      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formattedNow() {
    final now = DateTime.now();
    return DateFormat("d MMM''yy HH:mm:ss").format(now);
  }

  void _showResultBottomSheet(
    Map<String, dynamic> data,
    double temperature,
    double humidity,
    double soil,
  ) {
    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.rl)),
      ),
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height - mediaQuery.padding.top - 8,
      ),
      builder: (_) {
        final List recommendations = data['recommendation'];

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacingSize.l,
              right: AppSpacingSize.l,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "lib/assets/images/gemini_color.png", // ganti sesuai path kamu
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "AI Plant Analysis",
                            style: TextStyle(
                              fontSize: AppFontSize.l,
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        _formattedNow(),
                        style: TextStyle(
                          fontSize: AppFontSize.s,
                          color: Colors.grey[600],
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacingSize.l),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.rm),
                      border: Border.all(
                        color: AppColors.borderOrange,
                        width: 0.7,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacingSize.l),
                      child: Column(
                        spacing: AppSpacingSize.l,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: AppSpacingSize.xs,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedPinLocation01,
                                size: AppElementSize.sm,
                                color: AppColors.grayMedium,
                              ),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: AppFontSize.s,
                                    color: AppColors.grayMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: AppSpacingSize.xs,
                            children: [
                              HugeIcon(icon: HugeIcons.strokeRoundedPlant01),
                              Text(
                                plantName,
                                style: TextStyle(
                                  fontSize: AppFontSize.m,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              // === KOLOM 1 ===
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '$temperature°C',
                                        style: TextStyle(
                                          fontSize: AppFontSize.l + 2,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Temperature',
                                      style: TextStyle(fontSize: AppFontSize.s),
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 16),

                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${pumpUsage}x',
                                        style: TextStyle(
                                          fontSize: AppFontSize.l + 2,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Pump Usage',
                                      style: TextStyle(fontSize: AppFontSize.s),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // === KOLOM 2 ===
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '$soil%',
                                        style: TextStyle(
                                          fontSize: AppFontSize.l + 2,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Soil Moisture',
                                      style: TextStyle(fontSize: AppFontSize.s),
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 16),

                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        lastWatered,
                                        style: TextStyle(
                                          fontSize: AppFontSize.l + 2,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Last Watered',
                                      style: TextStyle(fontSize: AppFontSize.s),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // === KOLOM 3 ===
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '$humidity%',
                                        style: TextStyle(
                                          fontSize: AppFontSize.l + 2,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Humidity',
                                      style: TextStyle(fontSize: AppFontSize.s),
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 16),

                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '$currentWeek of $totalWeek',
                                        style: TextStyle(
                                          fontSize: AppFontSize.l + 2,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Progress (week)',
                                      style: TextStyle(fontSize: AppFontSize.s),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacingSize.s),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.rm),
                      border: Border.all(
                        color: AppColors.borderOrange,
                        width: 0.7,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacingSize.l),
                      child: Column(
                        spacing: AppSpacingSize.s,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: AppSpacingSize.xs,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: AppSpacingSize.xs,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedSoilMoistureField,
                                  ),
                                  Text(
                                    'Soil',
                                    style: TextStyle(
                                      fontSize: AppFontSize.l,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Ideal Range: ',
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                        // fontWeight: AppFontWeight.medium,
                                      ),
                                    ),
                                    TextSpan(
                                      text: data['soil_ideal_range'],
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                        fontWeight: AppFontWeight.bold,
                                        color: AppColors.success
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                data['soil_ideal_range_desc'],
                                style: TextStyle(
                                  fontSize: AppFontSize.s,
                                  color: AppColors.grayMedium,
                                ),
                              ),
                            ],
                          ),

                          Divider(color: AppColors.grayDivider),

                          Column(
                            spacing: AppSpacingSize.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: AppSpacingSize.xs,
                                children: [
                                  HugeIcon(
                                    icon:
                                        HugeIcons
                                            .strokeRoundedHealtcare,
                                  ),
                                  Text(
                                    'Plant Health',
                                    style: TextStyle(
                                      fontSize: AppFontSize.l,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Status: ',
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                      ),
                                    ),
                                    TextSpan(
                                      text: data['plant_health_status'],
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                        fontWeight: AppFontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Alert: ',
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                      ),
                                    ),
                                    TextSpan(
                                      text: data['plant_health_alert'],
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                        fontWeight: AppFontWeight.bold,
                                        color: AppColors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                data['plant_health_desc'],
                                style: TextStyle(
                                  fontSize: AppFontSize.s,
                                  color: AppColors.grayMedium,
                                ),
                              ),
                            ],
                          ),
                        
                          Divider(color: AppColors.grayDivider),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: AppSpacingSize.xs,
                                children: [
                                  HugeIcon(icon: HugeIcons.strokeRoundedAiIdea),
                                  Text(
                                    'Recommendations',
                                    style: TextStyle(
                                      fontSize: AppFontSize.l,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: AppSpacingSize.xs),

                              ...recommendations.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final item = entry.value;

                                return Padding(
                                  padding: EdgeInsets.only(top: 6, left: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$index.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppFontSize.m,
                                        ),
                                      ),

                                      SizedBox(width: AppFontSize.xs+3),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(item['desc']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacingSize.l),

                  ButtonAiWidget(
                    text: 'Reanalyze',
                    onPressed: () {
                      context.pop();
                      _handleAnalyzeAI(temperature, humidity, soil);
                    },
                    pngAsset: "lib/assets/images/gemini.png",
                  ),

                  SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);

    final sensor = ref.watch(sensorProvider); // WEBSOCKET

    final deviceState = ref.watch(deviceProvider);

    final pairState = deviceState.activePairState;

    _logSecureStorage();

    final temperature = sensor.temperature ?? 0.0;
    final humidity = sensor.humidity ?? 0.0;
    final soil = sensor.soil ?? 0.0;

    if (pairState is PairedNoPlant) {
      logger.i("Pair tanpa plant: $pairState");
    } else if (pairState is PairedWithPlant) {
      logger.i("Pair dengan plant: $pairState");
    } else {
      logger.i("Belum pair");
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacingSize.l,
              right: AppSpacingSize.l,
              top: mq.notchHeight * 1.5,
            ),
            child: Column(
              children: [
                (pairState == null)
                    ? AppBarWidget(
                      type: AppBarType.withoutNotif,
                      title: "Hi, Hydromers 👋",
                    )
                    : AppBarWidget(
                      type: AppBarType.main,
                      title: "Hi, Hydromers 👋",
                    ),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.rm),
                    border: Border.all(
                      color: AppColors.borderOrange,
                      width: 0.7,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacingSize.l),
                    //  ! TOP
                    child: Column(
                      children: [
                        // ? lokasi, suhu, logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: AppSpacingSize.xs,
                                    children: [
                                      Icon(Icons.pin_drop_outlined),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                            fontSize: AppFontSize.s,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacingSize.s),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        temperature.toString(),
                                        style: TextStyle(
                                          fontSize: AppFontSize.xxxl,
                                          fontWeight: AppFontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '°C',
                                        style: TextStyle(
                                          fontSize: AppFontSize.xl,
                                          fontWeight: AppFontWeight.semiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    weather,
                                    style: TextStyle(
                                      fontSize: AppFontSize.m,
                                      color: AppColors.gray,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'lib/assets/images/home_top.png',
                              width: 100,
                            ),
                          ],
                        ),

                        SizedBox(height: AppSpacingSize.xs),
                        Divider(color: AppColors.grayDivider),

                        SizedBox(height: AppSpacingSize.xs),

                        // ? humidity, moisture
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // HUMIDITY
                            Column(
                              spacing: AppSpacingSize.xs,
                              children: [
                                Text(
                                  'Humidity',
                                  style: TextStyle(
                                    fontSize: AppFontSize.m,
                                    fontWeight: AppFontWeight.semiBold,
                                  ),
                                ),
                                PieChartWidget(
                                  value: humidity,
                                  color: AppColors.blue,
                                ),
                                StatusIndicatorWidget(
                                  value: humidity,
                                  type: StatusType.humidity,
                                ),
                              ],
                            ),

                            // SOIL
                            Column(
                              spacing: AppSpacingSize.xs,
                              children: [
                                Text(
                                  'Soil Moisture',
                                  style: TextStyle(
                                    fontSize: AppFontSize.m,
                                    fontWeight: AppFontWeight.semiBold,
                                  ),
                                ),
                                PieChartWidget(
                                  value: soil,
                                  color: AppColors.success,
                                ),
                                StatusIndicatorWidget(
                                  value: soil,
                                  type: StatusType.soil,
                                  min: 40,
                                  max: 60,
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: AppSpacingSize.l),

                        Row(
                          spacing: AppSpacingSize.s,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: AppElementSize.s,
                              color: AppColors.gray,
                            ),
                            Expanded(
                              child: Text(
                                'Data is updated in real time and if the connection is green.',
                                style: TextStyle(
                                  fontSize: AppFontSize.xs,
                                  color: AppColors.gray,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSpacingSize.l),

                // ! PLANT ASSIST
                Row(
                  spacing: AppSpacingSize.s,
                  children: [
                    Icon(Icons.interests_outlined),
                    Text(
                      'Plant Assistant',
                      style: TextStyle(
                        fontSize: AppFontSize.l,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacingSize.xs),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.rm),
                    border: Border.all(
                      color: AppColors.borderOrange,
                      width: 0.7,
                    ),
                  ),
                  child:
                      (isLoadingInit)
                          ? Padding(
                            padding: EdgeInsets.all(AppSpacingSize.l),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : (pairState == null)
                          ? Padding(
                            padding: EdgeInsets.all(AppSpacingSize.l),
                            child: Column(
                              spacing: AppSpacingSize.l,
                              children: [
                                Text(
                                  'Device Not Paired Yet',
                                  style: TextStyle(
                                    fontSize: AppFontSize.l,
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                                Image.asset(
                                  'lib/assets/images/no_plant_add.png',
                                  width: 126,
                                  height: 120,
                                ),
                                FittedBox(
                                  child: Text(
                                    'Make sure your device is paired to begin adding plants.',
                                    style: TextStyle(fontSize: AppFontSize.m),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : _buildUI(
                            pairState,
                            context,
                            temperature,
                            humidity,
                            soil,
                          ),
                ),

                SizedBox(height: AppSpacingSize.l),
              ],
            ),
          ),
          if (isLoading) LoadingWidget(),
        ],
      ),
    );
  }
}
