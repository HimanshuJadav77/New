import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class technology extends StatefulWidget {
  const technology({super.key});

  @override
  State<technology> createState() => _technologyState();
}

class _technologyState extends State<technology> {
  String? _selectedValue; // Store selected value
  final List<String> _items = ['Option 1', 'Option 2', 'Option 3'];

  String? _fileName;
  Uint8List? _fileBytes;
  html.File? _htmlFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.first.name;
        if (html.window.navigator.userAgent.contains('Chrome') ||
            html.window.navigator.userAgent.contains('Firefox')) {
          _fileBytes = result.files.single.bytes;
          _htmlFile = html.File(_fileBytes!, _fileName!);
        }
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_fileBytes == null) return;

    try {
      // Upload to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref('uploads/').child('$_fileName');

      final blob = html.Blob([_htmlFile!]);
      await storageRef.putBlob(blob);

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('pdfs').add({
        'fileName': _fileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': Timestamp.now(),
      });

      // Reset the state
      if (mounted) {
        setState(() {
          _fileName = null;
          _fileBytes = null;
          _htmlFile = null;
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload successful!')));
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload failed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload PDF')),
      body: Center(
        child: Container(
          height: 700,
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(40),
                  value: _selectedValue,
                  hint: const Text('Select Collection of Upload'),
                  items: _items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue; // Update the selected value
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    disabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Selected File'),
                  controller: TextEditingController(text: _fileName),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Select PDF File'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadFile,
                  child: const Text('Upload PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
