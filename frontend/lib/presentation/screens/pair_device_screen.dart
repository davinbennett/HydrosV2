import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/core/utils/validator.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/providers/device_provider.dart';
import 'package:frontend/presentation/providers/injection.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:frontend/presentation/states/device_state.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/global/dialog.dart';
import 'package:frontend/presentation/widgets/global/loading.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

class PairDeviceScreen extends ConsumerStatefulWidget {
  const PairDeviceScreen({super.key});

  @override
  ConsumerState<PairDeviceScreen> createState() => _PairDeviceScreenState();
}

class _PairDeviceScreenState extends ConsumerState<PairDeviceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isFlashOn = false;
  final TextEditingController manualCodeController = TextEditingController();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  bool isLoading = false;

  String? deviceId;
  @override
  void initState() {
    super.initState();
    SecureStorage.getDeviceId().then((v) {
      deviceId = v;
      if (mounted) setState(() {});
    });
  }


  Future<void> _handleManualCode(String code) async {
    setState(() => isLoading = true);
    final authState = ref.read(authProvider).value;

    int? userId;
    if (authState is AuthAuthenticated) {
      userId = int.parse(authState.user.userId);
    } else {
      throw Exception("Not authenticated");
    }
    final pairDeviceController = ref.read(pairDeviceControllerProvider);
    try {
      final result2 = await pairDeviceController.pairDevice(code, userId);

      if (!mounted) return;

      setState(() => isLoading = false);

      if (result2 is PairedNoPlant) {
        // SET GLOBAL STATE
        ref.read(deviceProvider.notifier).setPairedNoPlant(code);

        await DialogWidget.showSuccess(
          context: context,
          title: "Successfully paired",
          message:
              'Your device with code "$code" has been successfully paired.',
          onOk: () {
            context.go('/home'); // balik ke screen sebelumnya
          },
        );
      } else if (result2 is DevicePairFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result2.message)));
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pair device.")));
    }
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (result?.code == scanData.code) return;

      setState(() {
        result = scanData;
      });

      final authState = ref.read(authProvider).value;

      int? userId;
      if (authState is AuthAuthenticated) {
        userId = int.parse(authState.user.userId);
      } else {
        return;
      }

      final pairDeviceController = ref.read(pairDeviceControllerProvider);
      try {
        setState(() => isLoading = true);
        final result2 = await pairDeviceController.pairDevice(
          scanData.code ?? '',
          userId,
        );

        if (!mounted) return;

        setState(() => isLoading = false);

        if (result2 is PairedNoPlant) {
          // SET GLOBAL STATE
          ref
              .read(deviceProvider.notifier)
              .setPairedNoPlant(scanData.code ?? '');

          await DialogWidget.showSuccess(
            context: context,
            title: "Successfully paired",
            message:
                'Your device with code "${scanData.code}" has been successfully paired.',
            onOk: () {
              context.go('/home'); // balik ke screen sebelumnya
            },
          );
        } else if (result2 is DevicePairFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result2.message)));
        }
      } catch (e) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pair device.")));
      }
    });
  }

  Future<void> _toggleFlash() async {
    await controller?.toggleFlash();
    bool? flashStatus = await controller?.getFlashStatus();
    setState(() => isFlashOn = flashStatus ?? false);
  }

  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final qrText = await QrCodeToolsPlugin.decodeFrom(image.path);

      if (qrText == null || qrText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR code not found in image.")),
        );
        return;
      }

      setState(() {
        result = Barcode(qrText, BarcodeFormat.qrcode, []);
      });

      final authState = ref.read(authProvider).value;

      int? userId;
      if (authState is AuthAuthenticated) {
        userId = int.parse(authState.user.userId);
      } else {
        return;
      }

      final pairDeviceController = ref.read(pairDeviceControllerProvider);
      try {
        setState(() => isLoading = true);
        final result2 = await pairDeviceController.pairDevice(qrText, userId);

        if (!mounted) return;

        setState(() => isLoading = false);

        if (result2 is PairedNoPlant) {
          // SET GLOBAL STATE
          ref.read(deviceProvider.notifier).setPairedNoPlant(qrText);

          await DialogWidget.showSuccess(
            context: context,
            title: "Successfully paired",
            message:
                'Your device with code \"$qrText\" has been successfully paired.',
            onOk: () {
              context.go('/home'); // balik ke screen sebelumnya
            },
          );
        } else if (result2 is DevicePairFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result2.message)));
        }
      } catch (e) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pair device.")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to read QR Code.")));
    }
  }

  Widget _pairedUI(BuildContext context, WidgetRef ref, MediaQueryHelper mq) {
    return Center(child: Text("PAIRED Page"));
  }

  Widget _scanUI(BuildContext context, WidgetRef ref, MediaQueryHelper mq) {
    return Stack(
      children: [
        Positioned.fill(
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppColors.success,
              borderRadius: AppRadius.rl,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: mq.screenWidth * 0.75,
            ),
          ),
        ),

        // Tombol Back kiri atas
        Positioned(
          top: mq.notchHeight * 1.5,
          left: 8,
          child: IconButton(
            onPressed: () => context.go('/home'),
            icon: Icon(
              Icons.arrow_back,
              size: AppElementSize.l,
              color: AppColors.white,
            ),
          ),
        ),

        // Tombol di kanan atas
        Positioned(
          top: mq.notchHeight * 1.5,
          right: 8,
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: AppElementSize.l,
                ),
              ),
              IconButton(
                onPressed: _scanFromGallery,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                  size: AppElementSize.l,
                ),
              ),
            ],
          ),
        ),

        DraggableScrollableSheet(
          initialChildSize: 0.05,
          minChildSize: 0.05,
          maxChildSize: 0.366,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.rxl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Text(
                      "Enter Code Manually",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormFieldWidget(
                      controller: manualCodeController,
                      validator: AppValidator.
                      deviceCodeRequired,
                      label: "Enter device code"
                    ),
                    SizedBox(height: 20),
                    ButtonWidget(
                      text: "Pair Device",
                      onPressed:
                          () => _handleManualCode(manualCodeController.text),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    final deviceState = ref.watch(deviceProvider);

    final isPaired = deviceState.hasPairedDevice;

    return Scaffold(
      body: Stack(
        children: [
          if (isPaired)
            _pairedUI(context, ref, mq)
          else
            _scanUI(context, ref, mq),

          if (isLoading) LoadingWidget(),
        ],
      ),
    );
  }
}
