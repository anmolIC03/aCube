import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('lib/assets/hero1.jpeg'),
              ),
            ),
            const SizedBox(height: 16),

            // Email TextField
            _buildTextField('Email', _emailController),
            const SizedBox(height: 16),

            // Password TextField
            _buildTextField('Password', _passwordController, isPassword: true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to change password screen or handle logic
                  print("Change Password Clicked");
                },
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                      textBaseline: TextBaseline.ideographic,
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

            const Text(
              'Bank Account Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField('Account Number', _accountNumberController),
            const SizedBox(height: 8),
            _buildTextField('Account Holder Name', _accountHolderController),
            const SizedBox(height: 8),
            _buildTextField('IFSC Code', _ifscController),
            const SizedBox(height: 24),

            // Save Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save functionality
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
