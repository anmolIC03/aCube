import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <String, CartItem>{}.obs;

  void addItem(CartItem item) {
    if (cartItems.containsKey(item.name)) {
      // If the item already exists, increment its quantity
      cartItems[item.name]!.incrementQuantity();
    } else {
      // If the item is not in the cart, add it with quantity 1
      cartItems[item.name] = item;
    }
    update();
  }

  void removeItem(String itemName) {
    if (cartItems.containsKey(itemName)) {
      var item = cartItems[itemName];
      if (item != null && item.quantity > 1) {
        // If quantity is greater than 1, decrement it
        item.decrementQuantity();
      } else {
        // If quantity becomes 0, remove the item from cart
        cartItems.remove(itemName);
      }
      update(); // Notify listeners for state update
    }
  }

  int calculateItemCount() {
    return cartItems.values
        .map((item) => item.quantity)
        .fold(0, (prev, current) => prev + current);
  }

  double calculateTotalPrice() {
    return cartItems.values
        .fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }
}
