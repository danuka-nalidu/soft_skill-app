import 'package:flutter/material.dart';
import 'package:uee_project/pages/app_main_screen.dart';
import 'package:uee_project/pages/forgot_password.dart';
import 'package:uee_project/pages/logout.dart';
import 'package:uee_project/pages/sign_up.dart';
import 'package:uee_project/widget/button.dart';
import 'package:uee_project/widget/text_field.dart';
import '../services/authentication.dart';
import '../widget/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    // Dispose controllers when widget is removed from the widget tree
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Method to handle user login
  void loginUsers() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "success") {
      // Navigate when login is successful
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AppMainScreen(),
        ),
      );
    } else {
      // Stop loading and show error message
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
            // Image section with top padding
            Padding(
              padding:
                  const EdgeInsets.only(top: 30.0), // Increase top padding here
              child: SizedBox(
                width: double.infinity,
                height: height / 3.5, // Adjust height to reduce image size
                child: Image.asset('images/login.jpg', fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 20), // Add spacing between image and text

            // Sign In Text
            const Text(
              "Sign In",
              style: TextStyle(
                fontFamily: 'Roboto', // Set the font family to Roboto
                fontSize: 28, // Increase font size
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 20), // Add spacing between text and input fields

            // Remaining space for input fields and buttons
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Email and Password Fields
                    TextFieldInput(
                      textEditingController: emailController,
                      hintText: 'Enter your email',
                      icon: Icons.email,
                    ),
                    TextFieldInput(
                      isPass: true,
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      icon: Icons.lock,
                    ),
                    MyButton(
                      onTab: loginUsers,
                      text: isLoading ? "Logging in..." : "Log In",
                    ),

                    // Forgot Password Section
                    const ForgotPassword(),

                    const SizedBox(height: 20),

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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.network(
                                "https://icon2.cleanpng.com/20240216/ikb/transparent-google-logo-google-logo-with-multicolored-g-and-1710875587855.webp",
                                height: 35,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Space before Sign Up section
                    // Don't have an account? Sign Up Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            " Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
