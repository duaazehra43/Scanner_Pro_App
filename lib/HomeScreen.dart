import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scan_pro_app/PDFViewScreen.dart';
import 'package:scan_pro_app/ViewScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _documents = [];
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    List<Map<String, dynamic>> loadedDocuments = [];
    try {
      final ListResult imagesResult = await _storage.ref('images').listAll();
      final ListResult filesResult = await _storage.ref('files').listAll();
      for (var ref in imagesResult.items) {
        final String url = await ref.getDownloadURL();
        final FullMetadata metadata = await ref.getMetadata();
        loadedDocuments.add({
          'url': url,
          'name': metadata.name,
          'size': metadata.size,
        });
      }
      for (var ref in filesResult.items) {
        final String url = await ref.getDownloadURL();
        final FullMetadata metadata = await ref.getMetadata();
        loadedDocuments.add({
          'url': url,
          'name': metadata.name,
          'size': metadata.size,
        });
      }
      setState(() {
        _documents = loadedDocuments;
      });
    } catch (e) {
      print('Error loading documents: $e');
    }
  }

  Future<void> _uploadFile(dynamic document) async {
    if (document is XFile) {
      await _uploadImageToFirebase(document);
    } else if (document is File) {
      await _uploadFileToFirebase(document);
    }
    _loadDocuments();
  }

  Future<void> _uploadImageToFirebase(XFile image) async {
    try {
      final file = File(image.path);
      final storageRef = _storage.ref().child('images/${image.name}');
      await storageRef.putFile(file);
      print('Image uploaded: ${image.name}');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _uploadFileToFirebase(File file) async {
    try {
      final storageRef =
          _storage.ref().child('files/${file.path.split('/').last}');
      await storageRef.putFile(file);
      print('File uploaded: ${file.path.split('/').last}');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? pickedImage = await _imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        await _uploadFile(pickedImage);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _uploadFile(file);
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  String _getFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }

  void _viewDocument(String url, String name) {
    if (name.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(pdfUrl: url),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentViewScreen(imageUrl: url),
        ),
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Choose Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Color(0xFF2F4FCD)),
                    const SizedBox(width: 10.0),
                    Text(
                      'From Gallery',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF2F4FCD),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.camera,
                      color: Color(0xFF2F4FCD),
                    ),
                    const SizedBox(width: 10.0),
                    Text('From Camera',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF2F4FCD),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickFile();
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFF2F4FCD),
                    ),
                    const SizedBox(width: 10.0),
                    Text('From Files',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF2F4FCD),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteDocument(int index) {
    String urlToDelete = _documents[index]['url'];
    _storage.refFromURL(urlToDelete).delete().then((_) {
      print('Successfully deleted document from Firebase Storage');
    }).catchError((error) {
      print('Error deleting document from Firebase Storage: $error');
    });

    setState(() {
      _documents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> recentDocuments = _documents.length > 5
        ? _documents.sublist(_documents.length - 5)
        : _documents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          height: 30,
          child: Text(
            "Scanner Pro",
            style: GoogleFonts.inter(
                color: const Color(0xFF2F4FCD), fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _documents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "You don't have any documents",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Recently Scanned",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentDocuments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          _viewDocument(recentDocuments[index]['url'],
                              recentDocuments[index]['name']);
                        },
                        child: Column(
                          children: [
                            Icon(
                              recentDocuments[index]['name']
                                      .toLowerCase()
                                      .endsWith('.pdf')
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                            Text(
                              recentDocuments[index]['name'],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "All Documents",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: Icon(
                        _documents[index]['name'].toLowerCase().endsWith('.pdf')
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: Colors.grey,
                      ),
                      title: Text(_documents[index]['name']),
                      subtitle: Text(_getFileSize(_documents[index]['size'])),
                      onTap: () {
                        _viewDocument(_documents[index]['url'],
                            _documents[index]['name']);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteDocument(index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        backgroundColor: const Color(0xFF2F4FCD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
