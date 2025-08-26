import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  final String phoneNumber;
  final Function onSuccess;

  const RegistrationScreen({
    Key? key,
    required this.phoneNumber,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool otpFieldVisible = false;
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://backend.acubemart.in/api/user/registerwithphone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': widget.phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => otpFieldVisible = true);
        Get.snackbar("OTP Sent", "Please enter the OTP sent to your phone.");
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Registration failed");
        setState(() => otpFieldVisible = true);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://backend.acubemart.in/api/user/verifyotpandlogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phoneNumber,
          'otp': otpController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          widget.onSuccess(data['data']);
          Get.snackbar("Success", "Account created & logged in!");
        } else {
          Get.snackbar("Error", data['message'] ?? "OTP verification failed");
        }
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
            "Error", errorData['message'] ?? "OTP verification failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, color: Color.fromRGBO(185, 28, 28, 1.0))
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Register",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: otpFieldVisible
                ? Column(
                    key: const ValueKey(1),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Enter the 6-digit OTP sent to your phone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("OTP", icon: Icons.lock),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed:
                            otpController.text.trim().length == 6 && !isLoading
                                ? verifyOtp
                                : null,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Verify & Continue",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey(2),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Complete your registration",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(185, 28, 28, 1.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration:
                            _inputDecoration("Name", icon: Icons.person),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        decoration: _inputDecoration("Email",
                            icon: Icons.email_outlined),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isLoading ? null : registerUser,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Register",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
