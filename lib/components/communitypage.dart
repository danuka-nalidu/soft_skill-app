import 'package:uee_project/components/wall_posts.dart';
import 'package:uee_project/helper/helper_method.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast package for showing toast messages
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for logged-in user details
import 'new_post.dart'; // Import the new post page

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String? currentUserEmail; // Nullable to store the logged-in user's email
  String searchQuery = ""; // Search query string

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

  // Function to delete a post
  void deletePost(String postId) async {
    DocumentSnapshot postDoc = await FirebaseFirestore.instance.collection('User Posts').doc(postId).get();
    Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
    String? imageUrl = postData['ImageURL'];

    if (imageUrl != null) {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete().then((_) {
        FirebaseFirestore.instance.collection('User Posts').doc(postId).delete();
        Fluttertoast.showToast(msg: "Post and associated image deleted successfully.");
      }).catchError((error) {
        Fluttertoast.showToast(msg: "Failed to delete image: $error");
      });
    } else {
      await FirebaseFirestore.instance.collection('User Posts').doc(postId).delete();
      Fluttertoast.showToast(msg: "Post deleted successfully.");
    }
  }

  // Function to edit a post
  void editPost(BuildContext context, String postId, String currentMessage) {
    TextEditingController editController = TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Edit Post",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: editController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Update your post...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (editController.text.trim().isNotEmpty) {
                        FirebaseFirestore.instance.collection('User Posts').doc(postId).update({
                          'Message': editController.text,
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Post updated successfully.");
                      } else {
                        Fluttertoast.showToast(msg: "Post cannot be empty.");
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explore Communities",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewPostPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          children: [
            // Search bar implementation
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase(); // Update the search query as user types
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamps", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var filteredDocs = snapshot.data!.docs.where((doc) {
                      String message = doc['Message'].toString().toLowerCase();
                      return message.contains(searchQuery); // Filter posts based on search query
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final post = filteredDocs[index];
                        final postId = post.id;
                        final postMessage = post['Message'];
                        final postUserEmail = post['User email'];
                        final postImageUrl = post.data().containsKey('ImageURL') ? post['ImageURL'] : null;

                        return Dismissible(
                          key: Key(postId),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              if (postUserEmail == currentUserEmail) {
                                editPost(context, postId, postMessage);
                                return false;
                              } else {
                                Fluttertoast.showToast(msg: "You cannot edit someone else's post.");
                                return false;
                              }
                            } else if (direction == DismissDirection.endToStart) {
                              if (postUserEmail == currentUserEmail) {
                                deletePost(postId);
                                return true;
                              } else {
                                Fluttertoast.showToast(msg: "You cannot delete someone else's post.");
                                return false;
                              }
                            }
                            return false;
                          },
                          child: WallPosts(
                            message: postMessage,
                            user: postUserEmail,
                            postId: postId,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: formatDate(post['TimeStamps']),
                            imageUrl: postImageUrl,
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}