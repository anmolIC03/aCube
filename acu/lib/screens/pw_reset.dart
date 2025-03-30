import 'package:flutter/material.dart';

class ResetPwScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPwScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;

  void _sendResetLink() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate sending a reset link
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to ${_emailController.text}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100), // Space for back button
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Enter your email address to request\na password reset.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 40),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'abc@email.com',
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Send Reset Link Button
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _sendResetLink,
                    child: _isProcessing
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'SEND',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Back Button to Login
                ],
              ),
            ),
          ),
          // Back Button positioned at top left
          Positioned(
            top: 40,
            left: 4,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to Login page
              },
            ),
          ),
        ],
      ),
    );
  }
}
