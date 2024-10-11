import 'package:flutter/material.dart';
import 'package:uee_project/pages/edit_profile.dart';
import 'package:uee_project/pages/lib_admin_page.dart';
import 'package:uee_project/pages/logout.dart'; // Import the logout page
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:uee_project/services/authentication.dart';

import 'add_skill.dart'; // Import AuthServices

class AdminProfile extends StatefulWidget {
  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String userName = ''; // Variable to store the admin's name

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch the admin's name when the page initializes
  }

  void fetchUserName() async {
    String? uid =
        FirebaseAuth.instance.currentUser?.uid; // Get the current admin's UID
    if (uid != null) {
      Map<String, dynamic>? userData = await AuthServices().getUserData(uid);
      if (mounted) {
        setState(() {
          userName = userData?['name'] ?? ''; // Set the admin's name
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
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
                      userName, // Use the fetched admin's name here
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

          Divider(color: Colors.grey), // Add divider

          // Admin Dashboard Section
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Panel',
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

          // Account Section (for admin)
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
                      'Add skill',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // Navigate to AddSkillForm when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddSkillForm()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Add book',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // Navigate to AddSkillForm when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminPage()),
                      );
                    },
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
                          builder: (context) =>
                              const Logout(), // Use the existing Logout class
                        ),
                      );
                    },
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
