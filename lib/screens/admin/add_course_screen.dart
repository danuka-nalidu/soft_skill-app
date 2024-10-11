import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import 'course_list_screen.dart';

class AddCourseScreen extends StatefulWidget {


  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _tutorController = TextEditingController();
  String? _selectedCategory;
  final _categories = ['Speaking', 'Decision making', 'Verbal Communication', 'Conflict Resolution', 'Analytical thinking'];
  List<File> _selectedImages = [];  // To store selected images
  List<File> _selectedDocs = [];    // To store selected documents
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _tutorController.dispose();
    super.dispose();
  }

  // Pick images using image_picker
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // Pick documents using file_picker
  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedDocs = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  // Upload files to Firebase Storage and return their URLs
  Future<List<String>> _uploadFiles(List<File> files, String folderName) async {
    List<String> downloadUrls = [];
    for (var file in files) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('$folderName/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  // Handle form submission and upload
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;  // Show loading indicator
      });

      // Upload images and documents to Firebase Storage
      List<String> imageUrls = await _uploadFiles(_selectedImages, 'media');
      List<String> docUrls = await _uploadFiles(_selectedDocs, 'documents');

      // Add course data to Firestore
      await FirebaseFirestore.instance.collection('courses').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory!,
        'duration': _durationController.text,
        'tutor': _tutorController.text,
        'media': imageUrls,  // Store the image URLs
        'files': docUrls,    // Store the document URLs
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course added successfully!')),
      );

      // Navigate to the course list page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CourseListScreen()),
      );
    }

    setState(() {
      _isLoading = false;  // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Enter Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text('Select Category'),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(labelText: 'Duration'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the duration';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _tutorController,
                    decoration: InputDecoration(labelText: 'Tutor Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the tutor name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Button to pick images
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text('Pick Images'),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    children: _selectedImages.map((file) {
                      return Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Button to pick documents
                  // ElevatedButton(
                  //   onPressed: _pickDocuments,
                  //   child: Text('Pick PDFs'),
                  // ),
                  // SizedBox(height: 10),
                  // Wrap(
                  //   children: _selectedDocs.map((file) {
                  //     return ListTile(
                  //       leading: Icon(Icons.insert_drive_file),
                  //       title: Text(file.path.split('/').last),
                  //     );
                  //   }).toList(),
                  // ),
                  // SizedBox(height: 20),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: Text('Submit'),
                  ),
                ],
              ),

              // Loading indicator while uploading
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
