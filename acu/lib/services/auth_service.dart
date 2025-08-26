import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// A dedicated class to handle all authentication-related API calls.
// This separates business logic from the UI.
class AuthService {
  // The base URL for your API. Storing it here makes it easy to change.
  static const String _baseUrl = "https://acubemart.in/api";

  // A reusable helper for making POST requests.
  // It handles JSON encoding, headers, and basic response parsing.
  static Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } on SocketException {
      // Handle network errors specifically.
      throw Exception(
          "No Internet connection. Please check your network and try again.");
    } catch (e) {
      // Handle other potential errors during the request.
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // API call to request an OTP for a given phone number.
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    return await _post("sendotp", {"phone": phone});
  }

  // API call to verify the OTP and log the user in.
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    return await _post("loginwithphoneotp", {"phone": phone, "otp": otp});
  }

  // API call to register a new user with their details.
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    // Note: The backend for registration doesn't seem to need the OTP itself,
    // just the user details. The login happens in a separate step.
    return await _post("registerwithphone", {
      "name": name,
      "email": email,
      "phone": phone,
    });
  }
}
