import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class QRCodeGeneratorApp extends StatefulWidget {
  const QRCodeGeneratorApp({super.key});

  @override
  QRCodeGeneratorAppState createState() => QRCodeGeneratorAppState();
}

class QRCodeGeneratorAppState extends State<QRCodeGeneratorApp> {
  String _inputText = '';
  final GlobalKey _qrKey = GlobalKey();

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onChanged: (text) {
          setState(() {
            _inputText = text;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Entrez le texte pour générer le code QR',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Container(
          color: Colors.white,
          child: RepaintBoundary(
            key: _qrKey,
            child: QrImage(
              data: _inputText,
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _saveQRCodeToGallery() async {
    RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final result = await ImageGallerySaver.saveImage(byteData!.buffer.asUint8List());

    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code QR sauvegardé dans la galerie.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sauvegarde du code QR.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTextInput(),
            const SizedBox(height: 20.0),
            _buildQRCode(),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveQRCodeToGallery,
              child: const Text('Télécharger le code QR'),
            ),
          ],
        ),
      ),
    );
  }
}