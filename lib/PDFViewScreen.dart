import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PdfViewerPage extends StatefulWidget {
  final File? pdfFile;
  final String? pdfUrl;

  const PdfViewerPage({Key? key, this.pdfFile, this.pdfUrl})
      : assert(pdfFile != null || pdfUrl != null);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  File? _downloadedPdfFile;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (widget.pdfUrl != null) {
      final http.Response response = await http.get(Uri.parse(widget.pdfUrl!));
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File(path.join(tempDir.path, 'temp_pdf.pdf'));
      await tempFile.writeAsBytes(response.bodyBytes);
      setState(() {
        _downloadedPdfFile = tempFile;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final fileToDisplay = widget.pdfFile ?? _downloadedPdfFile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: fileToDisplay != null
          ? SfPdfViewer.file(fileToDisplay)
          : Center(
              child: Text('Failed to load PDF'),
            ),
    );
  }
}
