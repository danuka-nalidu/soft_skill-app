import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uee_project/pages/edit_profile.dart';
import 'package:uee_project/pages/login.dart'; // Import LoginScreen
import 'package:uee_project/pages/logout.dart'; // Import the logout page
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:uee_project/services/authentication.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import toast

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = ''; // Variable to store the user's name

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch the user's name when the page initializes
  }

  void fetchUserName() async {
    String? uid =
        FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID
    if (uid != null) {
      Map<String, dynamic>? userData = await AuthServices().getUserData(uid);
      if (mounted) {
        setState(() {
          userName = userData?['name'] ?? ''; // Set the user's name
        });
      }
    }
  }

  Future<void> deleteProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Deleting the user's document from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Deleting the user's account from Firebase Auth
        await user.delete();

        // Show toast message
        Fluttertoast.showToast(
          msg: "Account deleted successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate to LoginScreen after deletion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteProfile(); // Call delete profile method
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        titleTextStyle: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
        backgroundColor: Colors.blue, // Set the app bar color to blue
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue, // Set the background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20.0), // Add left padding here
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('images/avatar.png'), // Image path updated
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userName, // Use the fetched user's name here
                      style: TextStyle(
                        fontSize: 22, // Adjust font size
                        fontWeight: FontWeight.w500,
                        color: Colors.white, // Change text color to white
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.white), // Edit icon color
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditDetailsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Learning Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '2+ hours',
                    style: TextStyle(
                      fontSize: 20, // Adjust font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Total Learn'),
                ],
              ),
              Container(width: 1, height: 30, color: Colors.grey),
              Column(
                children: [
                  Text(
                    '20',
                    style: TextStyle(
                      fontSize: 20, // Adjust font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Skills Gained'),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey), // Add divider

          // Dashboard Section
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.blue),
                    title: Text('Settings'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.card_membership, color: Colors.yellow),
                    title: Text('Skills and certifications'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '2 New',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.grey),
                    title: Text('Privacy'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Action Needed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Account Section
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Logout Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      // Navigate to Logout screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Logout(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _showDeleteConfirmationDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
