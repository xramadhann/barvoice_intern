import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:just_audio/just_audio.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudioFromQRCode(String qrData) async {
    if (qrData.startsWith("http")) {
      // Jika data adalah URL, unduh audio dan mainkan dari URL
      await audioPlayer.setUrl(qrData);
    } else {
      // Jika data adalah path file audio lokal, mainkan dari file lokal
      await audioPlayer.setFilePath(qrData);
    }
    await audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) async {
            await _playAudioFromQRCode(scanData as String);
          });
        },
      ),
    );
  }
}
