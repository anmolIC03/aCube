import 'dart:convert';
import 'package:acu/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OtpLoginScreen extends StatefulWidget {
  final Function onSuccess;

  const OtpLoginScreen({super.key, required this.onSuccess});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool otpSent = false;
  bool isNewUser = false;
  bool isLoading = false;

  // ✅ Track OTP validity
  bool get isOtpValid => _otpController.text.trim().length == 6;

  Future<void> sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar("Error", "Please enter your phone number");
      return;
    }

    try {
      final url = Uri.parse("https://backend.acubemart.in/api/user/sendotp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      final bodyString = response.body.trim();

      if (bodyString.isEmpty) {
        Get.snackbar("Error", "Server returned an empty response");
        return;
      }

      if (bodyString.startsWith("<!DOCTYPE html>") ||
          bodyString.startsWith("<html")) {
        final regExp = RegExp(r'Error:\s*(.*?)<br>', caseSensitive: false);
        final match = regExp.firstMatch(bodyString);
        final errorMsg =
            match != null ? match.group(1) ?? "Server error" : "Server error";

        if (errorMsg.toLowerCase().contains("no user found")) {
          setState(() => isNewUser = true);
          Get.snackbar("Info", "No user found, please register.");
          Get.to(() => RegistrationScreen(
              phoneNumber: phone, onSuccess: widget.onSuccess));
        } else {
          Get.snackbar("Error", errorMsg);
        }
        return;
      }

      Map<String, dynamic> bodyJson;
      try {
        bodyJson = jsonDecode(bodyString);
      } catch (_) {
        Get.snackbar("Error", "Invalid JSON from server: $bodyString");
        return;
      }

      final messageLower = bodyJson['message']?.toString().toLowerCase() ?? "";

      if (messageLower.contains('not registered') ||
          messageLower.contains('register')) {
        setState(() => isNewUser = true);
        Get.to(() => RegistrationScreen(
              phoneNumber: phone,
              onSuccess: widget.onSuccess,
            ));
        return;
      }

      if (response.statusCode == 200 && bodyJson['success'] == true) {
        setState(() {
          otpSent = true;
          isNewUser = messageLower.contains('register');
        });
        Get.snackbar("OTP Sent", "Please enter the OTP sent to your phone.");
      } else {
        Get.snackbar("Error", bodyJson['message'] ?? "Something went wrong.");
      }
    } catch (e) {
      Get.snackbar("Error", "Unexpected error: $e");
      print(e);
    }
  }

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    final String url = isNewUser
        ? 'https://backend.acubemart.in/api/user/verifyotpandlogin'
        : 'https://backend.acubemart.in/api/user/loginwithphoneotp';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final userId = body['data']['_id'];
        final storage = GetStorage();
        storage.write('userId', userId);

        widget.onSuccess(body['data']);
        Get.snackbar("Success", "Logged in successfully");
      } else {
        Get.snackbar("Error", body['message'] ?? "Invalid OTP");
      }
    } else {
      Get.snackbar("Error", "Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text("LOGIN",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 64, color: Color.fromRGBO(185, 28, 28, 1.0)),
                  const SizedBox(height: 12),
                  Text(
                    otpSent
                        ? "Enter the OTP sent to your phone"
                        : "Enter your phone number",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    enabled: !otpSent,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (otpSent) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Enter OTP",
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        counterText: "",
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          otpSent ? (isOtpValid ? verifyOtp : null) : sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                        disabledBackgroundColor: Colors.red.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              otpSent ? "Verify OTP" : "Send OTP",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
