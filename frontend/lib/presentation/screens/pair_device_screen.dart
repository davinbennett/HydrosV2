
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
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

    return Scaffold(
      body: Stack(
        children: [
          // Kamera QR
          Positioned.fill(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppColors.success,
                borderRadius: 12,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: mq.screenWidth * 0.7,
              ),
            ),
          ),

          // Tombol Back kiri atas
          Positioned(
            top: mq.notchHeight * 1.5,
            left: AppSpacingSize.l,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                size: AppElementSize.m,
              ),
            ),
          ),

          // Tombol di kanan atas
          Positioned(
            top: mq.notchHeight * 1.5,
            right: AppSpacingSize.l,
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleFlash,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: AppElementSize.l,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _scanFromGallery,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
          if (result != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'QR Result: ${result!.code}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
