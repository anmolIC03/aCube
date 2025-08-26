import 'package:acu/screens/components/cart_components/guestCartController.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'cart_controller.dart';
import 'cart_item.dart';

class CartManager extends GetxController {
  final guestCart = Get.put(GuestCartController());
  final cart = Get.put(CartController(), permanent: true);

  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = GetStorage().read("userId") != null;
  }

  /// Add item to cart
  void addItem(CartItem item) {
    if (isLoggedIn.value) {
      cart.addItem(item.productId);
    } else {
      guestCart.addToCart(item);
    }
  }

  /// Remove item
  void removeItem(String productId) {
    if (isLoggedIn.value) {
      cart.removeItem(productId);
    } else {
      guestCart.removeFromCart(productId);
    }
  }

  /// Increase quantity
  void increaseQty(String productId) {
    if (isLoggedIn.value) {
      final current =
          cart.cartItems.firstWhereOrNull((e) => e.productId == productId);
      if (current != null) {
        cart.updateQuantity(productId, current.quantity + 1);
      }
    } else {
      guestCart.increment(productId);
    }
  }

  /// Decrease quantity
  void decreaseQty(String productId) {
    if (isLoggedIn.value) {
      final current =
          cart.cartItems.firstWhereOrNull((e) => e.productId == productId);
      if (current != null && current.quantity > 1) {
        cart.updateQuantity(productId, current.quantity - 1);
      } else {
        cart.removeItem(productId);
      }
    } else {
      guestCart.decrement(productId);
    }
  }

  /// Get cart items
  List<CartItem> get items {
    return isLoggedIn.value ? cart.cartItems : guestCart.cartItems;
  }

  /// Total cart price
  double get totalPrice {
    return isLoggedIn.value
        ? cart.totalPrice
        : guestCart.cartItems
            .fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  /// Total item count
  int get itemCount {
    return isLoggedIn.value
        ? cart.itemCount
        : guestCart.cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Clear cart
  void clearCart() {
    if (isLoggedIn.value) {
      cart.clearCart();
    } else {
      guestCart.cartItems.clear();
      guestCart.saveCart();
    }
  }
}
