import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GuestCartController extends GetxController {
  final storage = GetStorage();
  final cartItems = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  void loadCart() {
    final saved = storage.read<List>('guest_cart') ?? [];
    cartItems.assignAll(
        saved.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e))));
  }

  void saveCart() {
    storage.write('guest_cart', cartItems.map((e) => e.toJson()).toList());
  }

  void addToCart(CartItem item) {
    final index = cartItems.indexWhere((e) => e.productId == item.productId);
    if (index == -1) {
      cartItems.add(item);
    } else {
      final updated =
          cartItems[index].copyWith(quantity: cartItems[index].quantity + 1);
      cartItems[index] = updated;
    }
    saveCart();
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.productId == productId);
    saveCart();
  }

  void increment(String productId) {
    final index = cartItems.indexWhere((e) => e.productId == productId);
    if (index != -1) {
      cartItems[index] =
          cartItems[index].copyWith(quantity: cartItems[index].quantity + 1);
      saveCart();
    }
  }

  void decrement(String productId) {
    final index = cartItems.indexWhere((e) => e.productId == productId);
    if (index != -1 && cartItems[index].quantity > 1) {
      cartItems[index] =
          cartItems[index].copyWith(quantity: cartItems[index].quantity - 1);
    } else if (index != -1) {
      cartItems.removeAt(index);
    }
    saveCart();
  }

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}
