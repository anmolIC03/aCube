import 'dart:convert';
import 'package:acu/screens/pay_methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrderConfirmScreenAlt extends StatefulWidget {
  final List<Map<String, dynamic>> orderedItems;
  final Map<String, dynamic> userData;
  final double deliveryCharges;
  final double codCharges;

  const OrderConfirmScreenAlt({
    Key? key,
    required this.orderedItems,
    required this.userData,
    required this.deliveryCharges,
    required this.codCharges,
  }) : super(key: key);

  @override
  _OrderConfirmScreenAltState createState() => _OrderConfirmScreenAltState();
}

class _OrderConfirmScreenAltState extends State<OrderConfirmScreenAlt> {
  final storage = GetStorage();
  Rxn<Map<String, dynamic>> selectedAddress = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;

  late TextEditingController streetCtrl,
      cityCtrl,
      stateCtrl,
      countryCtrl,
      pinCtrl;

  @override
  void initState() {
    super.initState();
    streetCtrl = TextEditingController();
    cityCtrl = TextEditingController();
    stateCtrl = TextEditingController();
    countryCtrl = TextEditingController();
    pinCtrl = TextEditingController();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    setState(() => isLoading.value = true);
    final userId = widget.userData['_id'];
    final response = await http.get(
      Uri.parse('https://backend.acubemart.in/api/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body['success'] == true &&
          body['data'] != null &&
          (body['data']['address'] as List).isNotEmpty) {
        selectedAddress.value = (body['data']['address'] as List).first;

        streetCtrl.text = selectedAddress.value?['street'] ?? '';
        cityCtrl.text = selectedAddress.value?['city'] ?? '';
        stateCtrl.text = selectedAddress.value?['state'] ?? '';
        countryCtrl.text = selectedAddress.value?['country'] ?? '';
        pinCtrl.text = selectedAddress.value?['pincode'] ?? '';
      }
    } else {
      Get.snackbar("Error", "Failed to fetch address");
    }

    setState(() => isLoading.value = false);
  }

  double get subtotal => widget.orderedItems.fold(
        0.0,
        (sum, item) =>
            sum + (item['price']?.toDouble() ?? 0.0) * (item['quantity'] ?? 1),
      );

  double get total => subtotal + widget.deliveryCharges + widget.codCharges;

  Future<void> _saveOrUpdateAddress() async {
    final userId = storage.read("userId");
    if (userId == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    final fullAddress =
        "${streetCtrl.text}, ${cityCtrl.text}, ${stateCtrl.text}, ${countryCtrl.text} - ${pinCtrl.text}";

    final bodyData = {
      'street': streetCtrl.text,
      'city': cityCtrl.text,
      'state': stateCtrl.text,
      'country': countryCtrl.text,
      'pincode': pinCtrl.text,
      'fullAddress': fullAddress,
    };

    try {
      late http.Response response;

      if (selectedAddress.value != null) {
        final addressId = selectedAddress.value!['_id'];
        response = await http.patch(
          Uri.parse(
              'https://backend.acubemart.in/api/address/update/$addressId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyData),
        );
      } else {
        bodyData['userId'] = userId;
        response = await http.post(
          Uri.parse('https://backend.acubemart.in/api/address/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyData),
        );
      }

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        Get.snackbar("Success", "Address saved successfully");
        await _loadAddress();
      } else {
        Get.snackbar("Error", body['message'] ?? "Failed to save address");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            (Icons.arrow_back_ios_new),
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: const Text(
          "Confirm Your Order",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Customer Info"),
              _infoCard([
                _infoText("Name", widget.userData['name']),
                _infoText("Phone", widget.userData['phone']),
              ]),
              const SizedBox(height: 16),
              _sectionTitle(selectedAddress.value != null
                  ? "Edit Address"
                  : "Add Address"),
              _infoCard([
                _buildTextField("Street", streetCtrl),
                _buildTextField("City", cityCtrl),
                _buildTextField("State", stateCtrl),
                _buildTextField("Country", countryCtrl),
                _buildTextField("Pincode", pinCtrl,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveOrUpdateAddress,
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Save Address",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(185, 28, 28, 1.0)),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _sectionTitle("Order Summary"),
              ...widget.orderedItems.map((item) => _buildCartItemCard(item)),
              const Divider(height: 32),
              _sectionTitle("Price Breakdown"),
              _infoCard([
                _buildPriceRow("Subtotal", subtotal),
                _buildPriceRow("Delivery Charges", widget.deliveryCharges),
                _buildPriceRow("COD Charges", widget.codCharges),
                const Divider(),
                _buildPriceRow("Total", total, isBold: true),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedAddress.value == null) {
                      Get.snackbar("Error", "Please save address first");
                      return;
                    }

                    final addressId = selectedAddress.value!['_id'];
                    final phone = widget.userData['phone'] ?? '';

                    final int totalAmount = total.toInt();

                    Get.to(() => PaymentMethodsScreen(
                          products: widget.orderedItems,
                          addressId: addressId,
                          phone: phone,
                          totalAmount: totalAmount,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text(
                    "Place Order",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> item) {
    final itemName = item['name'] ?? '';
    final quantity = item['quantity'] ?? 1;
    final price = (item['price'] ?? 0).toDouble();
    final total = (price * quantity).toStringAsFixed(2);
    final List<dynamic> imagesRaw = item['image'] ?? item['images'] ?? [];
    final String? firstImage =
        imagesRaw.isNotEmpty ? imagesRaw.first.toString() : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Icon (can be replaced with image)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(185, 28, 28, 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: firstImage != null
                  ? Image.network(
                      firstImage,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey),
                    )
                  : Icon(Icons.image, size: 48, color: Colors.grey),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Quantity: $quantity",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Total Price
            SizedBox(width: 15),
            Text(
              "₹$total",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15)),
            Text("₹${amount.toStringAsFixed(2)}",
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15)),
          ],
        ),
      );

  Widget _infoText(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text("$label: $value",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
      );

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );

  Widget _buildCustomerAddressSection() {
    final name = widget.userData['name'] ?? '';
    final phone = widget.userData['phone'] ?? '';
    final address = selectedAddress.value;

    final fullAddress = address != null
        ? "${address['street']}, ${address['city']}, ${address['state']}\n${address['country']} - ${address['pincode']}"
        : "No address found.";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: Colors.red.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Scroll to address form or expand it if needed
                        // You can use a scroll controller or showModalBottomSheet if you want
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "+91 $phone",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fullAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
