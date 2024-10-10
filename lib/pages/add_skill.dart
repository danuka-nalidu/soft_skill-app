import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddSkillForm extends StatefulWidget {
  @override
  _AddSkillFormState createState() => _AddSkillFormState();
}

class _AddSkillFormState extends State<AddSkillForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _courseCountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _isFavourite = false;
  File? _imageFile;
  final picker = ImagePicker();

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Upload image to Firebase Storage and get URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().toString()}');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  // Save the form data to Firestore
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile != null) {
        final imageUrl = await _uploadImage(_imageFile!);

        if (imageUrl != null) {
          FirebaseFirestore.instance.collection('SoftSkills').add({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'coursecount': int.parse(_courseCountController.text),
            'isfavourite': _isFavourite,
            'category': _categoryController.text,
            'imageurl': imageUrl,
          }).then((_) {
            Fluttertoast.showToast(msg: 'Skill added successfully!');
            _formKey.currentState!.reset();
          }).catchError((error) {
            Fluttertoast.showToast(msg: 'Error: $error');
          });
        } else {
          Fluttertoast.showToast(msg: 'Failed to upload image.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Please select an image.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Skill'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Skill Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the skill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _courseCountController,
                decoration: const InputDecoration(labelText: 'Course Count'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course count';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Is Favourite'),
                value: _isFavourite,
                onChanged: (bool value) {
                  setState(() {
                    _isFavourite = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  const SizedBox(width: 20),
                  if (_imageFile != null) const Text('Image Selected'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
