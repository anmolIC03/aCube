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

  Future<void> fetchCart() async {
    final userId = storage.read("userId");

    if (userId == null) {
      List<dynamic> guestCart = storage.read('guestCart') ?? [];
      cartItems.assignAll(guestCart.map((e) => CartItem.fromJson(e)).toList());
      cartItems.refresh();
      print("Guest cart loaded: ${cartItems.length} items");
      return;
    }

    final url = Uri.parse("$apiBaseUrl/all/?userId=$userId");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          final List products = responseData["data"]["products"];
          cartItems.assignAll(
              products.map((item) => CartItem.fromJson(item)).toList());
          cartItems.refresh();
          print("Fetched cart: ${cartItems.length} items");
        } else {
          print("Backend responded with success: false");
        }
      } else {
        print(
            "Failed to fetch cart: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception during fetchCart: $e");
    }
  }

  Future<void> addItem(String productId) async {
    final userId = storage.read("userId");

    isLoading.value = true;

    if (userId == null) {
      _addToLocalCart(productId);
      isLoading.value = false;
      return;
    }

    int index = cartItems.indexWhere((item) => item.productId == productId);

    if (index != -1) {
      final newQty = cartItems[index].quantity + 1;
      await updateQuantity(productId, newQty);
    } else {
      final body = json.encode({
        "userId": userId,
        "productId": productId,
        "quantity": 1,
      });

      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/add'),
          body: body,
          headers: {"Content-Type": "application/json"},
        );

        print("Add Item Response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 201) {
          await fetchCart();
        } else {
          print("Error adding item: ${response.body}");
        }
      } catch (e) {
        print('Error adding item to cart: $e');
      }
    }

    isLoading.value = false;
  }

  void _addToLocalCart(String productId) {
    List<dynamic> guestCart = storage.read('guestCart') ?? [];

    int index = guestCart.indexWhere((item) => item['productId'] == productId);
    if (index != -1) {
      guestCart[index]['quantity'] += 1;
    } else {
      guestCart.add({
        'productId': productId,
        'name': '',
        'price': 0,
        'quantity': 1,
        'images': [],
        'brand': '',
      });
    }

    storage.write('guestCart', guestCart);
    cartItems.assignAll(guestCart.map((e) => CartItem.fromJson(e)).toList());
    cartItems.refresh();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final userId = storage.read("userId");
    if (userId == null) return;

    final body = json.encode({
      "userId": userId,
      "productId": productId,
      "quantity": quantity,
    });

    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/update'),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      print(
          "Update Quantity Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        // Update local list too
        int index = cartItems.indexWhere((item) => item.productId == productId);
        if (index != -1) {
          cartItems[index] = cartItems[index].copyWith(quantity: quantity);
          cartItems.refresh();
        }

        await fetchCart(); // Ensure consistency with backend
      } else {
        print("Failed to update cart quantity: ${response.body}");
      }
    } catch (e) {
      print('Error updating cart item: $e');
    }
  }

  Future<void> removeItem(String productId) async {
    final userId = storage.read("userId");
    if (userId == null) return;

    final body = json.encode({
      "userId": userId,
      "productId": productId,
    });

    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/remove'),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      print("Remove Item Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        await fetchCart();
      } else {
        Get.snackbar("Error", "Failed to remove item from cart");
      }
    } catch (e) {
      print('Error removing cart item: $e');
      Get.snackbar("Error", "Something went wrong while removing the item");
    }
  }

  Future<void> clearCart() async {
    final userId = storage.read("userId");
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/clear'),
        body: json.encode({"userId": userId}),
        headers: {"Content-Type": "application/json"},
      );

      print("Clear Cart Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        cartItems.clear();
        cartItems.refresh();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);
}
