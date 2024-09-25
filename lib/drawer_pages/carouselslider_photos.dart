import 'dart:typed_data';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CarouselsliderPhotos extends StatefulWidget {
  @override
  State<CarouselsliderPhotos> createState() => _CarouselsliderPhotosState();
}

class _CarouselsliderPhotosState extends State<CarouselsliderPhotos> {
  List<String> _fileNames = [];
  List<Uint8List?> _fileBytes = [];
  List<html.File?> _htmlFiles = [];
  bool _isUploading = false; // Track upload progress

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Allow multiple file selection
    );

    if (result != null) {
      setState(() {
        _fileNames.clear();
        _fileBytes.clear();
        _htmlFiles.clear();

        for (var file in result.files) {
          _fileNames.add(file.name);
          if (html.window.navigator.userAgent.contains('Chrome') ||
              html.window.navigator.userAgent.contains('Firefox')) {
            _fileBytes.add(file.bytes);
            _htmlFiles.add(html.File(file.bytes!, file.name));
          }
        }
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_fileBytes.isEmpty) return;

    setState(() {
      _isUploading = true; // Start uploading
    });

    try {
      for (int i = 0; i < _fileBytes.length; i++) {
        final fileName = _fileNames[i];
        final blob = html.Blob([_htmlFiles[i]!]);
        final storageRef =
            FirebaseStorage.instance.ref('uploads/').child(fileName);

        // Upload to Firebase Storage
        await storageRef.putBlob(blob);
      }

      // Reset the state
      if (mounted) {
        setState(() {
          _fileNames.clear();
          _fileBytes.clear();
          _htmlFiles.clear();
          _isUploading = false; // Reset upload state
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload successful!')));
    } catch (e) {
      print('Error uploading files: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload failed!')));
      if (mounted) {
        setState(() {
          _isUploading = false; // Reset upload state on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CarouselSlider Photos ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickFiles,
                    child: const Text('Pick Images'),
                  ),
                  const SizedBox(height: 20),
                  Text(_fileNames.isNotEmpty
                      ? 'Selected Files: ${_fileNames.join(', ')}'
                      : 'No files selected'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadFiles,
                    child: const Text('Upload Files'),
                  ),
                  // Show progress indicator if uploading
                  if (_isUploading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
