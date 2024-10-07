import 'package:flutter/material.dart';
import 'package:uee_project/pages/login.dart';
import 'package:uee_project/services/authentication.dart';
import 'package:uee_project/widget/snack_bar.dart';
import '../widget/button.dart';
import '../widget/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for email, password, and name fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    // Dispose controllers when widget is removed from the widget tree
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    String res = await AuthServices().signUpUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
    );

    if (res == "success") {
      setState(() {
        isLoading = true;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Image section
            SizedBox(
              width: double.infinity,
              height: height / 4.0, // Reduced the image height
              child: Image.asset('images/signup.jpeg', fit: BoxFit.cover),
            ),

            const SizedBox(height: 10), // Reduced spacing after image

            // Sign Up Text
            const Text(
              "Sign Up",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10), // Reduced spacing before input fields

            // Input Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFieldInput(
                      textEditingController: nameController,
                      hintText: 'Enter your name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 10), // Reduced spacing
                    TextFieldInput(
                      textEditingController: emailController,
                      hintText: 'Enter your email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 10), // Reduced spacing
                    TextFieldInput(
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      isPass: true,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 15), // Reduced spacing before button
                    MyButton(
                        onTab: signUpUser,
                        text: isLoading ? "Signing Up..." : "Sign Up"),

                    const SizedBox(
                        height: 10), // Reduced spacing before OR section

                    // ---- OR ---- divider
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("OR"),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Google Sign-In Button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        onPressed: () {
                          // Handle Google Sign-In
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.network(
                                "https://icon2.cleanpng.com/20240216/ikb/transparent-google-logo-google-logo-with-multicolored-g-and-1710875587855.webp",
                                height: 30, // Reduced image height
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18, // Reduced font size
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10), // Reduced spacing

                    // Already have an account? Login Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 14), // Reduced font size
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "  Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Reduced font size
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
