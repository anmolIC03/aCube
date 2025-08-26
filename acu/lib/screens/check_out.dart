import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final double deliveryCharges;
  final double codCharges;

  const CheckoutScreen({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.deliveryCharges,
    required this.codCharges,
    required this.productId,
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
    fetchAddresses();
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

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map && decodedResponse.containsKey("data")) {
          final user = decodedResponse["data"];
          if (user != null) {
            phoneNumber.value = user["phone"] ?? "";

            if (user.containsKey("address") && user["address"] is List) {
              addresses
                  .assignAll(List<Map<String, dynamic>>.from(user["address"]));

              if (addresses.isNotEmpty) {
                selectedAddress.value = addresses.first;
              }
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
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
        child: SingleChildScrollView(
          child: Obx(() {
            if (isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address Section
                Text("Delivery Address",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),

                if (selectedAddress.value != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildEditableField(
                            "Street",
                            selectedAddress.value!['street'],
                            (value) =>
                                selectedAddress.value!['street'] = value),
                        buildEditableField(
                            "City",
                            selectedAddress.value!['city'],
                            (value) => selectedAddress.value!['city'] = value),
                        buildEditableField(
                            "State",
                            selectedAddress.value!['state'],
                            (value) => selectedAddress.value!['state'] = value),
                        buildEditableField(
                            "Country",
                            selectedAddress.value!['country'],
                            (value) =>
                                selectedAddress.value!['country'] = value),
                        buildEditableField(
                            "Pincode",
                            selectedAddress.value!['pincode'],
                            (value) =>
                                selectedAddress.value!['pincode'] = value,
                            isNumeric: true),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Color.fromRGBO(185, 28, 28, 1.0))),
                          onPressed: () {
                            Get.snackbar("Update", "Address Updated");
                          },
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Save Address",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar("Add Address", "Add Address Clicked");
                    },
                    icon: Icon(Icons.add),
                    label: Text("Add Address"),
                  ),

                SizedBox(height: 16),

                // Contact Details Section
                Text("Contact Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: buildEditableField("Phone Number", phoneNumber.value,
                      (value) => phoneNumber.value = value,
                      isNumeric: true),
                ),

                SizedBox(height: 16),

                // Product Details Section
                Text("Product Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),

                Card(
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
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
            padding: EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (selectedAddress.value == null) {
              Get.snackbar(
                  "Error", "Please add a delivery address before proceeding");
              return;
            }

            Get.to(() => OrderConfirmScreen(
                  productName: widget.productName,
                  productImage: widget.productImage,
                  productPrice: widget.productPrice,
                  deliveryCharges: widget.deliveryCharges,
                  codCharges: widget.codCharges,
                  productId: widget.productId,
                  addressId: selectedAddress.value!['_id'] ?? "",
                  phone: phoneNumber.value,
                ));
          },
          child: Text("Continue",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildEditableField(
      String label, String value, Function(String) onChanged,
      {bool isNumeric = false}) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
    );
  }
}
