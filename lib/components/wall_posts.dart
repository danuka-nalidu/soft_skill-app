import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uee_project/components/comment.dart';
import 'package:uee_project/components/comment_button.dart';
import 'package:uee_project/components/like_button.dart';
import 'package:uee_project/helper/helper_method.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For image storage
import 'package:image_picker/image_picker.dart'; // For selecting images
import 'dart:io';
import 'package:http/http.dart' as http; // Add this import for API requests
import 'dart:convert'; // To parse JSON

class WallPosts extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final String? imageUrl; // Add imageUrl to the constructor for image fetching

  const WallPosts({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    this.imageUrl, // Optional image URL
  });

  @override
  State<WallPosts> createState() => _WallPostsState();
}

class _WallPostsState extends State<WallPosts> {
  String currentUserEmail = ''; // Remove hardcoded email
  bool isLiked = false;
  final _commentTextController = TextEditingController();
  File? _imageFile; // To store the selected image
  String? profileImageUrl; // Store the random profile image URL

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUserEmail);
    fetchUserDetails(); // Fetch the current user's details
    fetchRandomProfileImage(); // Fetch the random profile image when the widget is created
  }

    void fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email ?? 'unknown';
      });
    }
  }


  // Fetch random profile image from randomuser.me API
  Future<void> fetchRandomProfileImage() async {
    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profileImageUrl = data['results'][0]['picture']['thumbnail']; // Get the profile image URL
        });
      } else {
        print('Failed to load random profile image');
      }
    } catch (e) {
      print('Error fetching random profile image: $e');
    }
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef = FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUserEmail])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUserEmail])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).collection("Comments").add({
      "CommentText": commentText,
      "CommentedBy": currentUserEmail,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_commentTextController.text.isNotEmpty) {
                addComment(_commentTextController.text);
                Navigator.pop(context);
                _commentTextController.clear();
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the random profile image near the post
              if (profileImageUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl!),
                  radius: 20,
                ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.user,
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text("•", style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            widget.time,
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Show uploaded image if it exists
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.network(widget.imageUrl!),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  const SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 5),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('0', style: TextStyle(color: Colors.grey));
                      }
                      final commentCount = snapshot.data!.docs.length;
                      return Text(
                        commentCount.toString(),
                        style: const TextStyle(color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;
                  final commentUser = commentData["CommentedBy"] ?? "Unknown user";

                  return Comment(
                    text: commentData["CommentText"],
                    user: commentUser,
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
