import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';

class UpdateCourseScreen extends StatefulWidget {
  final CourseModel course;
  final int index;

  UpdateCourseScreen({required this.course, required this.index});

  @override
  _UpdateCourseScreenState createState() => _UpdateCourseScreenState();
}

class _UpdateCourseScreenState extends State<UpdateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _tutorController = TextEditingController();
  String? _selectedCategory;
  List<String> _existingMedia = [];
  List<File> _newImages = [];
  List<File> _newDocs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.course.title;
    _descriptionController.text = widget.course.description;
    _durationController.text = widget.course.duration;
    _tutorController.text = widget.course.tutor;
    _selectedCategory = widget.course.category;
    _existingMedia = widget.course.media;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _tutorController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _newImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _newDocs = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

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

  Future<void> _updateCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      List<String> newImageUrls = await _uploadFiles(_newImages, 'media');
      List<String> updatedMedia = _existingMedia + newImageUrls;

      await FirebaseFirestore.instance.collection('courses').doc(widget.course.id).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory!,
        'duration': _durationController.text,
        'tutor': _tutorController.text,
        'media': updatedMedia,
      });

      // Update local provider state
      final updatedCourse = CourseModel(
        id: widget.course.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        duration: _durationController.text,
        tutor: _tutorController.text,
        media: updatedMedia,
        files: widget.course.files,
      );

      await Provider.of<CourseProvider>(context, listen: false).updateCourse(updatedCourse, widget.index);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course updated successfully!')));
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Course')),
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
                    maxLength: 50,
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
                    items: ['Development', 'Design', 'Marketing', 'Business'].map((String category) {
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
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(labelText: 'Description'),
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
                    maxLength: 50,
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
                    maxLength: 50,
                    decoration: InputDecoration(labelText: 'Tutor Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the tutor name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  Text('Existing Images:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Wrap(
                    children: _existingMedia.map((url) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _existingMedia.remove(url);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),

                  // Pick new images
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text('Pick New Images'),
                  ),
                  SizedBox(height: 10),

                  Wrap(
                    children: _newImages.map((file) {
                      return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateCourse,
                    child: Text('Update Course'),
                  ),
                ],
              ),
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
