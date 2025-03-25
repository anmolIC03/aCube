import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final userId = GetStorage().read("userId");
    if (userId == null) {
      print("User ID not found");
      return;
    }
    print(userId);
    final url = Uri.parse("https://backend.acubemart.in/api/user/$userId");

    try {
      final response = await http.get(url);
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody["data"] != null && responseBody["data"].isNotEmpty) {
          final data = responseBody["data"];

          setState(() {
            _emailController.text = data["email"] ?? "";
            if (data["address"].isNotEmpty) {
              _addressController.text = data["address"][0]["street"] ?? "";
              _pincodeController.text = data["address"][0]["pincode"] ?? "";
              _cityController.text = data["address"][0]["city"] ?? "";
              _stateController.text = data["address"][0]["state"] ?? "";
              _countryController.text = data["address"][0]["country"] ?? "";
            }
          });
        } else {
          print("No user data found");
        }
      } else {
        print("Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          const AssetImage('lib/assets/hero1.jpeg'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Email', _emailController),
                  const SizedBox(height: 16),
                  _buildTextField('Password', _passwordController,
                      isPassword: true),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        print("Change Password Clicked");
                      },
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(185, 28, 28, 1.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Business Address Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField('Address', _addressController),
                  const SizedBox(height: 8),
                  _buildTextField('Pincode', _pincodeController),
                  const SizedBox(height: 8),
                  _buildTextField('City', _cityController),
                  const SizedBox(height: 8),
                  _buildTextField('State', _stateController),
                  const SizedBox(height: 8),
                  _buildTextField('Country', _countryController),
                  const SizedBox(height: 24),
                  // const Text(
                  //   'Bank Account Details',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // _buildTextField('Account Number', _accountNumberController),
                  // const SizedBox(height: 8),
                  // _buildTextField(
                  //     'Account Holder Name', _accountHolderController),
                  // const SizedBox(height: 8),
                  // _buildTextField('IFSC Code', _ifscController),
                  // const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Saved Changes');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'SAVE',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
