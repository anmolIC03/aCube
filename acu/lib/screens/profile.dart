import 'dart:convert';
import 'package:acu/screens/components/hidden_drawer.dart';
import 'package:acu/screens/otpSheet.dart';
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

  bool isLoading = true;
  String? addressId;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProfileData();
    });
  }

  bool get isLoggedIn => storage.read("userId") != null;

  Future<void> saveProfile() async {
    final userId = storage.read("userId");
    if (userId == null) {
      _showSnackBar("Please login to save profile.");
      return;
    }

    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "user": userId,
      "street": _addressController.text.trim(),
      "pincode": _pincodeController.text.trim(),
      "city": _cityController.text.trim(),
      "state": _stateController.text.trim(),
      "country": _countryController.text.trim(),
    });

    final Uri url = addressId != null
        ? Uri.parse(
            "https://backend.acubemart.in/api/address/update/$addressId")
        : Uri.parse("https://backend.acubemart.in/api/address/add");

    try {
      final response = addressId != null
          ? await http.patch(url, headers: headers, body: body)
          : await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Address saved successfully!");
        fetchProfileData();
      } else {
        _showSnackBar("Failed to save address: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error saving address: $e");
    }
  }

  Future<void> fetchProfileData() async {
    final userId = storage.read("userId");
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("https://backend.acubemart.in/api/user/$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody["success"] == true && responseBody["data"] is Map) {
          final user = responseBody["data"];
          final List<dynamic> addressList = user["address"] ?? [];

          setState(() {
            _emailController.text = user["email"] ?? "";
            if (addressList.isNotEmpty) {
              final address = addressList.first;
              addressId = address["_id"];
              _addressController.text = address["street"] ?? "";
              _pincodeController.text = address["pincode"] ?? "";
              _cityController.text = address["city"] ?? "";
              _stateController.text = address["state"] ?? "";
              _countryController.text = address["country"] ?? "";
            }
          });
        }
      } else {
        _showSnackBar("Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error fetching profile: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isLoggedIn
              ? _buildProfileForm()
              : _buildLoginCard(),
    );
  }

  Widget _buildLoginCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline,
                    size: 64, color: Color.fromRGBO(185, 28, 28, 1.0)),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to AcubeMart",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login or sign up to manage your profile, orders, and more.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpLoginScreen(
                            onSuccess: (userData) {
                              storage.write('userId', userData['_id']);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => HiddenDrawer()),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("LOGIN / REGISTER",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage('lib/assets/hero1.jpeg'),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Email', _emailController),
          const SizedBox(height: 16),
          _buildTextField('Password', _passwordController, isPassword: true),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(185, 28, 28, 1.0),
                ),
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
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('SAVE',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
