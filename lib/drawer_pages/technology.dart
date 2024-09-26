import 'dart:io';
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
  TextEditingController folderNameController = TextEditingController();
  String? _selectedField;
  String? _selectecTechField;
  List<String> fields = [
    "Software Development",
    "Networking",
    "CyberSecurity",
    "Data Science",
    "Artificial intelligence",
  ];
  Map<String, List<String>> techfieldMapping = {
    "Software Development": [
      "Web Development",
      "Mobile App Development",
      "Game Development",
      "Database Management",
      "Cloud Computing",
    ],
    "Networking": [
      'Network Engineering',
      'Network security',
      'wireless Networking',
    ],
    "CyberSecurity": [
      "Ethical Hacking",
      "Penetration Testing",
      "Incident Response",
      "Digital Forensics",
    ],
    "Data Science": [
      'Data Analysis',
      'Data Mining',
      'Machine Learning',
    ],
    "Artificial intelligence": [
      'Application of AI',
      'History of AI',
      'Types of AI',
    ]
  };

  late final List<String> _fileNames = [];
  final List<Uint8List?> _fileBytes = [];
  final List<html.File?> _htmlFiles = [];
  bool _isUploading = false;
  bool _selecting = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true, // Allow multiple file selection
    );

    if (result != null) {
      setState(() {
        _fileNames.clear();
        _fileBytes.clear();
        _htmlFiles.clear();
        _selecting = true;

        for (var file in result.files) {
          _fileNames.add(file.name);
          if (html.window.navigator.userAgent.contains('Chrome') ||
              html.window.navigator.userAgent.contains('Firefox')) {
            _fileBytes.add(file.bytes);
            _htmlFiles.add(html.File(file.bytes!, file.name));
          }
        }
        _selecting = false;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_fileBytes.isNotEmpty &&
        _selectedField != "" &&
        _selectecTechField != "" &&
        folderNameController.text != "") {
      try {
        setState(() {
          _isUploading = true; // Start uploading
        });
        for (int i = 0; i < _fileBytes.length; i++) {
          final fileName = _fileNames[i];
          final blob = html.Blob([_htmlFiles[i]!]);
          final storageRef =
              FirebaseStorage.instance.ref('TechnologiesPDF/').child(fileName);
          final uploaded = await storageRef.putBlob(blob);
          final pdfURL = uploaded.ref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection("TechnologiesPDF")
              .doc(_selectedField)
              .collection("$_selectecTechField")
              .doc(folderNameController.text.trim().toString())
              .set({
            "filename": fileName.trim().toString(),
            "fileurl": pdfURL.toString()
          });
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 5,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          showCloseIcon: true,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.black,
          content: const Text(
            'Please Select Collection,Docs And Enter Folder Name!',
            style: TextStyle(color: Colors.red),
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technology PDFs')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          borderRadius: BorderRadius.circular(40),
                          value: _selectedField,
                          hint: const Text('Select Collection of Upload'),
                          items: fields.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedField = newValue;
                              _selectecTechField = null;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          borderRadius: BorderRadius.circular(40),
                          value: _selectecTechField,
                          hint: const Text('Select Collection of Upload'),
                          items: _selectedField != null
                              ? techfieldMapping[_selectedField]
                                  ?.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList()
                              : null,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectecTechField = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: folderNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Folder Name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.folder_copy_outlined),
                            label: const Text(
                              'Enter PDF Folder Name',
                              style: TextStyle(fontSize: 13),
                            ),
                            // hintText: 'Enter Email',
                            hintStyle: const TextStyle(color: Colors.black26),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _pickFiles,
                      child: const Text('Select PDF Files'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _uploadFiles,
                      child: const Text('Upload PDFs'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fileNames.clear();
                          _fileBytes.clear();
                          _htmlFiles.clear();
                        });
                      },
                      child: const Text('Clear Selected PDF'),
                    ),
                  ],
                ),
                Container(
                  color: Colors.black12,
                  height: 500,
                  child: Row(
                    children: [
                      if (_fileNames.isNotEmpty)
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Selected PDF: ",
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 150),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _fileNames
                                    .map((fileName) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                fileName,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blueGrey),
                                              ),
                                              const Divider(
                                                thickness: 5,
                                                color: Colors.green,
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_isUploading || _selecting)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
