import 'dart:convert';

import 'package:acu/screens/login_page.dart';
import 'package:acu/screens/verify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> registerUser() async {
    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("All fields are required!");
      return;
    }
    if (password != confirmPassword) {
      _showMessage("Passwords do not match!");
      return;
    }

    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('https://backend.acubemart.in/api/user/register');

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {"name": fullName, "email": email, "password": password}));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.to(VerificationScreen(email: email));
      } else {
        _showMessage(responseData['message'] ?? "Signup failed. Try again");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  // Full Name TextField
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Confirm Password TextField
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 60),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle sign-up logic
                      isLoading ? null : registerUser();
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      textStyle: TextStyle(fontSize: 16, color: Colors.white),
                      backgroundColor:
                          Color.fromRGBO(185, 28, 28, 1.0), // Custom red color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // OR
                  Center(
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Login with Google and Facebook
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Google login logic
                          },
                          icon: Image.asset(
                            'lib/assets/download.jpeg',
                            width: 24,
                            height: 24,
                          ),
                          label: Text(
                            'Sign Up with Google',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 60),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Facebook login logic
                          },
                          icon: Icon(
                            Icons.facebook,
                            color: Color.fromARGB(255, 47, 78, 104),
                          ),
                          label: Text(
                            'Sign Up with Facebook',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Already have an account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          // Navigate to login page
                          Get.to(() => LoginPage());
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                              color: Color.fromRGBO(185, 28, 28, 1.0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Back Button positioned at the top-left
          Positioned(
            top: 40, // Position the button near the top
            left: 5, // Align it to the left
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
