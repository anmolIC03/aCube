import 'dart:convert';

import 'package:acu/screens/components/hidden_drawer.dart';
import 'package:acu/screens/home.dart';
import 'package:acu/screens/pw_reset.dart';
import 'package:acu/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscureText = true;
  bool isLoading = false;

  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter email & password");
      return;
    }
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('https://backend.acubemart.in/api/user/login/');
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"email": email, "password": password}));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        //String token = responseData['token'];

        Get.snackbar("Success", "Login successful!");
        Get.offAll(() => HiddenDrawer()); // Navigate to the home screen
      } else {
        Get.snackbar("Error", responseData["message"]);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong. Try again later.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the left
            children: [
              SizedBox(height: 60),
              Text(
                'ACUBEMART',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 130),
              Text(
                'Sign In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

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

              // Password TextField with Eye Icon
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
                      _obscureText ? Icons.visibility_off : Icons.visibility,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _rememberMe,
                          onChanged: (bool value) {
                            setState(() {
                              _rememberMe = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.orange,
                        ),
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password logic
                      Get.to(() => ResetPwScreen());
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Sign In Button with Custom Color
              ElevatedButton(
                onPressed: () {
                  // Handle sign-in logic
                  isLoading ? null : login();
                },
                child: Text(
                  'Sign In',
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
                child: Text('OR',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
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
                        'Login with Google',
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
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Facebook login logic
                      },
                      icon: Icon(
                        Icons.facebook,
                        color: const Color.fromARGB(255, 47, 78, 104),
                      ),
                      label: Text(
                        'Login with Facebook',
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

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign-up page
                      Get.to(() => SignupPage());
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Color.fromRGBO(185, 28, 28, 1.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
