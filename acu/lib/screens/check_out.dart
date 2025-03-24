import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String productName;
  final String productImage;
  final double productPrice;
  final double productRating;
  final double deliveryCharges;
  final double codCharges;

  const CheckoutScreen({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productRating,
    required this.deliveryCharges,
    required this.codCharges,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  var isLoading = true.obs;
  var addresses = <Map<String, dynamic>>[].obs;
  var selectedAddress = Rxn<Map<String, dynamic>>();
  final storage = GetStorage();
  var phoneNumber = "".obs;

  @override
  void initState() {
    super.initState();
    print("Stored userId: ${storage.read("userId")}");

    Future.delayed(Duration.zero, () => fetchAddresses());
  }

  // Fetch Addresses from API
  Future<void> fetchAddresses() async {
    try {
      final userId = storage.read("userId");
      if (userId == null) {
        Get.snackbar("Error", "No logged-in user found!");
        return;
      }

      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/user/$userId'),
        headers: {"Content-Type": "application/json"},
      );

      print("Fetch Address Response Status: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map && decodedResponse.containsKey("data")) {
          final user = decodedResponse["data"];

          if (user != null) {
            // ✅ Extract phone number
            phoneNumber.value = user["phone"] ?? "";

            // ✅ Extract addresses
            if (user.containsKey("address") && user["address"] is List) {
              addresses
                  .assignAll(List<Map<String, dynamic>>.from(user["address"]));

              if (addresses.isNotEmpty) {
                selectedAddress.value = addresses.first;
              } else {
                Get.snackbar("Error", "No addresses found for this user.");
              }
            } else {
              Get.snackbar("Error", "User has no address.");
            }
          }
        } else {
          Get.snackbar("Error", "Invalid API response: 'data' key missing.");
        }
      } else {
        Get.snackbar("Error", "Failed to load user details");
      }
    } catch (e, stacktrace) {
      print("Error: $e\nStacktrace: $stacktrace");
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Add New Address
  Future<void> addAddress(Map<String, dynamic> newAddress) async {
    try {
      final userId = storage.read("userId");
      if (userId == null) {
        Get.snackbar("Error", "No logged-in user found!");
        return;
      }

      final response = await http.post(
        Uri.parse('https://backend.acubemart.in/api/address/add'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": userId,
          ...newAddress,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Address added successfully",
            snackPosition: SnackPosition.BOTTOM);

        selectedAddress.value = newAddress;

        await fetchAddresses();
      } else {
        Get.snackbar("Error", "Failed to add address",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void openAddressDialog() {
    TextEditingController streetController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController stateController = TextEditingController();
    TextEditingController countryController = TextEditingController();
    TextEditingController pincodeController = TextEditingController();

    Get.defaultDialog(
      title: "Add New Address",
      content: Column(
        children: [
          TextField(
              controller: streetController,
              decoration: InputDecoration(labelText: "Street")),
          TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: "City")),
          TextField(
              controller: stateController,
              decoration: InputDecoration(labelText: "State")),
          TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: "Country")),
          TextField(
              controller: pincodeController,
              decoration: InputDecoration(labelText: "Pincode")),
        ],
      ),
      textConfirm: "Save",
      onConfirm: () {
        addAddress({
          "street": streetController.text,
          "city": cityController.text,
          "state": stateController.text,
          "country": countryController.text,
          "pincode": pincodeController.text,
        });
        Get.back();
      },
      textCancel: "Cancel",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text("Checkout"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, size: 26),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Section
              Text("Delivery Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              if (selectedAddress.value != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${selectedAddress.value!['street']}, ${selectedAddress.value!['city']}, ${selectedAddress.value!['state']}, ${selectedAddress.value!['country']}, ${selectedAddress.value!['pincode']}",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      IconButton(
                        onPressed: openAddressDialog,
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: openAddressDialog,
                  icon: Icon(Icons.add),
                  label: Text("Add Address"),
                ),
              SizedBox(height: 16),

              // Product Details Section
              Text("Product Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (selectedAddress.value == null) {
                    Get.snackbar("Error",
                        "Please add a delivery address before proceeding");
                    return;
                  }

                  Get.to(() => OrderConfirmScreen(
                        productName: widget.productName,
                        productImage: widget.productImage,
                        productPrice: widget.productPrice,
                        productRating: widget.productRating,
                        deliveryCharges: widget.deliveryCharges,
                        codCharges: widget.codCharges,
                        productId: '',
                        address: {},
                        phone: '',
                      ));
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Image.network(widget.productImage,
                            width: 100, height: 100, fit: BoxFit.cover),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.productName,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('₹${widget.productPrice}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
