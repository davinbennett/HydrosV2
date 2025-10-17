import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/providers/injection.dart';
import 'package:frontend/presentation/states/auth_state.dart';
import 'package:frontend/presentation/states/device_state.dart';
import 'package:frontend/presentation/widgets/global/loading.dart';
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

  Future<void> _onQRViewCreated(QRViewController controller) async {
    setState(() => isLoading = true);

    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (result?.code == scanData.code) return;

      setState(() {
        result = scanData;
      });

      final authState =
          ref
              .read(authProvider)
              .value;

      int? userId;
      if (authState is AuthAuthenticated) {
        userId = int.parse(authState.user.userId);
        logger.i("✅ User ID: $userId");
      } else {
        debugPrint("⚠️ User belum login");
        return;
      }

      final pairDeviceController = ref.read(pairDeviceControllerProvider);
      try {
        final result2 = await pairDeviceController.pairDevice(
          scanData.code ?? '',
          userId,
        );

        if (!mounted) return;

        setState(() => isLoading = false);

        if (result2 is PairedNoPlant) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "Device Paired Successfully 🎉",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  "Your device with code \"${scanData.code}\" has been successfully paired.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop(); // balik ke screen sebelumnya
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else if (result2 is DevicePairFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result2.message)));
        }
      } catch (e) {
        setState(() => isLoading = false);

        debugPrint("❌ Pairing gagal: $e");
      }
    });
  }


  Future<void> _toggleFlash() async {
    await controller?.toggleFlash();
    bool? flashStatus = await controller?.getFlashStatus();
    setState(() => isFlashOn = flashStatus ?? false);
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final qrText = await QrCodeToolsPlugin.decodeFrom(image.path);
      if (qrText != null) {
        setState(() {
          result = Barcode(qrText, BarcodeFormat.qrcode, []);
        });
      }
    } catch (e) {
      debugPrint("❌ Gagal membaca QR dari gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    if (result != null) {
      logger.i('QR Result: ${result!.code}');
    }

    return Scaffold(
      body: Stack(
        children: [
          if (isLoading) const LoadingWidget(),
          // Kamera QR
          Positioned.fill(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppColors.success,
                borderRadius: 12,
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
              onPressed: () => context.pop(),
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

          // Hasil Scan
          // if (result != null)
          //   Align(
          //     alignment: Alignment.center,
          //     child: Container(
          //       margin: EdgeInsets.all(16),
          //       padding: EdgeInsets.all(12),
          //       decoration: BoxDecoration(
          //         color: Colors.black54,
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: Text(
          //         'QR Result: ${result!.code}',
          //         style: TextStyle(color: Colors.white),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ),

          DraggableScrollableSheet(
            initialChildSize: 0.05,
            minChildSize: 0.05,
            maxChildSize: 0.245,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      TextField(
                        controller: manualCodeController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.qr_code_2_rounded),
                          hintText: "Enter device code...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            debugPrint(
                              "Manual code: ${manualCodeController.text}",
                            );
                          },
                          child: Text(
                            "Pair Device",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
