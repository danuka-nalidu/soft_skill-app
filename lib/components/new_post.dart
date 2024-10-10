import 'dart:io'; // For working with files
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:firebase_storage/firebase_storage.dart'; // For uploading to Firebase Storage
import 'package:lottie/lottie.dart'; // For Lottie animations
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController postController = TextEditingController();
  String? currentUserEmail; // Change this to nullable since we'll fetch it
  File? _selectedImage; // To store the selected image
  bool isLoading = false; // To show a loading spinner while uploading

  @override
  void initState() {
    super.initState();
    fetchUserEmail(); // Fetch the current user's email
  }

  // Fetch the logged-in user's email from Firebase Auth
  void fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserEmail = user?.email ?? 'Unknown';
    });
  }

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Function to upload image to Firebase Storage and get the download URL
  Future<String> uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  // Function to add a new post with an optional image
  Future<void> addNewPost() async {
    if (postController.text.isNotEmpty || _selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      FirebaseFirestore.instance.collection('User Posts').add({
        'User email': currentUserEmail,
        'Message': postController.text,
        'TimeStamps': Timestamp.now(),
        'Likes': [],
        'ImageURL': imageUrl, // Store the image URL if it exists
      }).then((_) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: addNewPost,
            child: const Text(
              "Publish",
              style: TextStyle(color: Color(0xFF8A99F3), fontSize: 16),
            ),
          ),
        ],
        backgroundColor: const Color(0xFFF5F5F5),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( 
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Lottie animation
                    Lottie.network(
                      'https://lottie.host/37524fe7-2d55-4c10-bdfc-2d754755aef3/p1JLay6UNp.json',
                      height: 350, 
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: postController,
                            decoration: const InputDecoration(
                              hintText: "Write your post here....",
                              border: InputBorder.none,
                            ),
                            maxLines: 4,
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt_outlined),
                                onPressed: pickImage,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_selectedImage!, height: 150),
                          )
                        : const Text('No image selected'),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }
}
