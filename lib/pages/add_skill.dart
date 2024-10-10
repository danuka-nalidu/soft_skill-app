import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uee_project/pages/home_screen.dart';

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

  // Save the form data to Firestore and navigate to HomeScreen
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
            Fluttertoast.showToast(
              msg: 'Skill added successfully!',
              backgroundColor: Colors.green, // Toast color for success
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
            );
            _formKey.currentState!.reset();
            // Navigate to your existing HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()), // Existing HomeScreen
            );
          }).catchError((error) {
            Fluttertoast.showToast(
              msg: 'Error: $error',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to upload image.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Please select an image.',
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Skill'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skill Name
              const Text(
                "Skill Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Skill Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the skill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Course Count
              TextFormField(
                controller: _courseCountController,
                decoration: InputDecoration(
                  labelText: 'Course Count',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
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
              // Category
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Favourite Switch
              SwitchListTile(
                title: const Text('Is Favourite'),
                value: _isFavourite,
                activeColor: Colors.blueAccent,
                onChanged: (bool value) {
                  setState(() {
                    _isFavourite = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Image Picker
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (_imageFile != null)
                    const Text(
                      'Image Selected',
                      style: TextStyle(color: Colors.green),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
