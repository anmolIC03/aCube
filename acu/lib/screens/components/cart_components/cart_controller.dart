import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_item.dart';

const String apiBaseUrl = 'https://backend.acubemart.in/api/cart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  final storage = GetStorage();
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchCart();
    super.onInit();
  }

  /// ✅ Fetch Cart from Backend
  void fetchCart() async {
    final userId = storage.read("userId");

    if (userId == null) {
      Get.snackbar("Error", "User ID not found. Please log in again.");
      return;
    }

    final url = Uri.parse("$apiBaseUrl/all/?userId=$userId");

    try {
      final response =
          await http.get(url, headers: {"Content-Type": "application/json"});

      print("Cart Response Status: ${response.statusCode}");
      print("Cart Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          final cartData = responseData["data"];
          final List products = cartData["products"];

          if (products.isNotEmpty) {
            cartItems.assignAll(
                products.map((item) => CartItem.fromJson(item)).toList());
          } else {
            cartItems.clear();
          }

          print("Cart Items Count: ${cartItems.length}");
          cartItems.refresh(); // Notify UI of changes
        }
      } else {
        Get.snackbar("Error", "Failed to fetch cart");
      }
    } catch (e) {
      print("Exception: $e");
      Get.snackbar("Error", "Something went wrong while fetching the cart");
    }
  }

  /// ✅ Add Product to Cart
  Future<void> addItem(String productId) async {
    final userId = GetStorage().read("userId");
    if (userId == null) return;

    isLoading.value = true; // Show loader

    // 🔥 Check if item is already in cart
    int index = cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      cartItems[index] =
          cartItems[index].copyWith(quantity: cartItems[index].quantity + 1);
      cartItems.refresh(); // 🔥 Update UI immediately
    } else {
      cartItems.add(CartItem(
        productId: productId,
        name: "", // Placeholder (fetchCart() will update real values)
        price: 0,
        quantity: 1,
        images: [],
        brand: "",
      ));
      cartItems.refresh(); // 🔥 Update UI immediately
    }

    final body =
        json.encode({"userId": userId, "productId": productId, "quantity": 1});

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/add'),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        fetchCart(); // ✅ Fetch latest cart data from backend
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print('Error adding item to cart: $e');
    } finally {
      isLoading.value = false; // Hide loader
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final userId = storage.read("userId");
    if (userId == null) return;

    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/update'),
        body: json.encode(
            {"userId": userId, "productId": productId, "quantity": quantity}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        int index = cartItems.indexWhere((item) => item.productId == productId);
        if (index != -1) {
          cartItems[index] = cartItems[index].copyWith(quantity: quantity);
          cartItems.refresh();
        }
        fetchCart(); // ✅ Ensure updated values from backend
      }
    } catch (e) {
      print('Error updating cart item: $e');
    }
  }

  Future<void> removeItem(String productId) async {
    final userId = storage.read("userId");
    if (userId == null) return;

    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/remove'),
        body: json.encode({"userId": userId, "productId": productId}),
        headers: {"Content-Type": "application/json"},
      );

      print("Remove Item Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        fetchCart(); // ✅ Fetch updated cart after removal
      } else {
        Get.snackbar("Error", "Failed to remove item from cart");
      }
    } catch (e) {
      print('Error removing cart item: $e');
      Get.snackbar("Error", "Something went wrong while removing the item");
    }
  }

  /// ✅ Clear Entire Cart
  Future<void> clearCart() async {
    final userId = GetStorage().read("userId");
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/clear'),
        body: json.encode({"userId": userId}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        cartItems.clear();
        cartItems.refresh(); // ✅ Notify UI of changes
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  /// ✅ Calculate Total Item Count
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// ✅ Calculate Total Cart Price
  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);
}
