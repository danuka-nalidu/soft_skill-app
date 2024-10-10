import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TestMe extends StatefulWidget {
  @override
  _TestMeState createState() => _TestMeState();
}

class _TestMeState extends State<TestMe> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController(); // For new comments
  final TextEditingController editCommentController = TextEditingController(); // For editing comments
  String? selectedCommentId; // Holds the ID of the comment being edited
  String loggedUserName = ''; // Variable to hold the logged-in user's name

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
    fetchComments(); // Fetch comments on page load
    fetchUserDetails(); // Fetch user details
  }

  List filedata = [];

  Future<void> fetchComments() async {
    // Fetch comments from Firebase
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Comments').orderBy('date', descending: true).get();
    setState(() {
      filedata = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'pic': doc['pic'],
                'message': doc['message'],
                'date': doc['date'],
              })
          .toList();
    });
  }

  // Fetch the logged-in user's details from Firestore
  Future<void> fetchUserDetails() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        loggedUserName = userDoc['name'] ?? 'Unknown User'; // Fetch the user's name
      });
    }
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 20),
            Icon(Icons.delete, color: Colors.white),
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.blue[800],
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.edit, color: Colors.white),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget commentChild(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          background: slideLeftBackground(), // Swipe left to delete
          secondaryBackground: slideRightBackground(), // Swipe right to edit
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe Left to delete
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Confirmation"),
                    content: Text("Are you sure you want to delete this comment?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteComment(data[index]['id']);
                          Navigator.of(context).pop(true);
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Swipe Right to edit
              editCommentController.text = data[index]['message']; // Set the message in the edit controller
              selectedCommentId = data[index]['id']; // Store the comment ID for editing
              
              // Show the edit modal
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: EdgeInsets.only(top: 10.0),
                    content: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Edit Comment",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: editCommentController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Edit your comment...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  label: Text("Cancel"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    editComment(selectedCommentId!, editCommentController.text);
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.save),
                                  label: Text("Save"),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
              return false;
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    print("Comment Clicked");
                  },
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: CommentBox.commentImageParser(imageURLorPath: data[index]['pic']),
                    ),
                  ),
                ),
                title: Text(
                  data[index]['name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data[index]['message']),
                trailing: Text(data[index]['date'], style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
        );
      },
    );
  }

  void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey[800],
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


   Future<void> postComment() async {
    if (formKey.currentState!.validate()) {
      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      await FirebaseFirestore.instance.collection('Comments').add({
        'name': loggedUserName, // Use the fetched user name here
        'pic': 'https://randomuser.me/api/portraits/men/${filedata.length % 100}.jpg',
        'message': commentController.text,
        'date': formattedDate,
      });

      fetchComments();
      commentController.clear();
      FocusScope.of(context).unfocus();

      showToast("Comment posted successfully!");
    }
  }

Future<void> deleteComment(String commentId) async {
  await FirebaseFirestore.instance.collection('Comments').doc(commentId).delete();
  fetchComments();

  showToast("Comment deleted successfully!");
}

Future<void> editComment(String commentId, String newMessage) async {
  await FirebaseFirestore.instance.collection('Comments').doc(commentId).update({
    'message': newMessage,
    'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
  });

  fetchComments();

  showToast("Comment updated successfully!");
}


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comment Page"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: CommentBox(
          userImage: CommentBox.commentImageParser(imageURLorPath: "lib/assets/user.png"),
          child: commentChild(filedata),
          labelText: 'Write a comment...',
          errorText: 'Comment cannot be blank',
          withBorder: false,
          sendButtonMethod: postComment,
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Colors.blue[800],
          textColor: Colors.white,
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}