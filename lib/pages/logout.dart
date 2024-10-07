import 'package:flutter/material.dart';
import 'package:uee_project/pages/login.dart';
import 'package:uee_project/widget/button.dart';

import '../services/authentication.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center the entire Column both horizontally and vertically
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Makes the column as small as possible
          mainAxisAlignment:
              MainAxisAlignment.center, // Centers content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centers content horizontally
          children: [
            const Text(
              "Congratulations!\nYou have successfully logged in",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(
                height: 20), // Add space between the text and the button
            MyButton(
              onTab: () async {
                await AuthServices().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              text: "Log out",
            ),
          ],
        ),
      ),
    );
  }
}
