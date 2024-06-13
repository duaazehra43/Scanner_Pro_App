import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DocumentViewScreen extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;

  DocumentViewScreen({this.imageFile, this.imageUrl})
      : assert(imageFile != null || imageUrl != null);

  @override
  _DocumentViewScreenState createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  String _extractedText = 'Extracting text...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performOCR();
  }

  Future<void> _performOCR() async {
    InputImage inputImage;

    if (widget.imageFile != null) {
      inputImage = InputImage.fromFilePath(widget.imageFile!.path);
    } else if (widget.imageUrl != null) {
      final http.Response response =
          await http.get(Uri.parse(widget.imageUrl!));
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File(path.join(tempDir.path, 'temp_image.jpg'));
      await tempFile.writeAsBytes(response.bodyBytes);
      inputImage = InputImage.fromFilePath(tempFile.path);
    } else {
      return;
    }

    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String extractedText = recognizedText.text;
    setState(() {
      _extractedText = extractedText;
      _isLoading = false;
    });

    textRecognizer.close();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document View'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageView(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _isLoading ? 'Extracting text...' : _extractedText,
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _copyToClipboard,
              icon: const Icon(Icons.copy, color: Colors.white),
              label: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                child: Text(
                  "Copy Text",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF2F4FCD)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageView() {
    if (widget.imageFile != null) {
      return Image.file(widget.imageFile!);
    } else if (widget.imageUrl != null) {
      return Image.network(widget.imageUrl!);
    } else {
      return Container(); // Placeholder for unexpected cases
    }
  }
}
