import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'scanner_page.dart'; // Import halaman scanner

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRGenerator(),
    );
  }
}

class QRGenerator extends StatefulWidget {
  @override
  _QRGeneratorState createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  List<String> qrDataList = [];
  String qrCodeData = '';
  TextEditingController nameController = TextEditingController();
  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference(); // Referensi database Firebase

  Future<void> pickAudioFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        qrDataList[index] = file.path!;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> saveToDatabase(
      String name, String eng, String ind, String man, String qrCode) async {
    try {
      await _databaseReference.child('data').set({
        'name': name,
        'eng': eng,
        'ind': ind,
        'man': man,
        'qrcode': qrCode,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved to database.'),
        ),
      );
    } catch (error) {
      print('Failed to save data: $error');
    }
  }

  void generateQRCode() {
    if (qrDataList.every((element) => element.isNotEmpty)) {
      String combinedData = qrDataList.join(", ");
      String name = nameController.text;
      saveToDatabase(
          name, qrDataList[0], qrDataList[1], qrDataList[2], combinedData);
      setState(() {
        qrCodeData = combinedData;
      });
    } else {
      // Show error message if not all files are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all 3 audio files.'),
        ),
      );
    }
  }

  void goToScanner() {
    if (qrDataList.every((element) => element.isNotEmpty)) {
      String combinedData = qrDataList.join(", ");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScanner(
            combinedData as List<String>,
          ),
        ),
      );
    } else {
      // Show error message if not all files are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all 3 audio files.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    qrDataList = List.generate(3, (_) => '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < qrDataList.length; i++)
              ElevatedButton(
                onPressed: () async {
                  await pickAudioFile(i);
                },
                child: Text('Pick Audio File ${i + 1}'),
              ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateQRCode,
              child: Text('Generate QR Code'),
            ),
            SizedBox(height: 20),
            qrCodeData.isNotEmpty
                ? QrImageView(
                    data: qrCodeData,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  )
                : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: qrDataList.every((element) => element.isNotEmpty)
                  ? goToScanner
                  : null,
              child: Text('Go to Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
