import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:get/get.dart';

class WishlistController extends GetxController {
  var wishlist = <CartItem>[].obs;

  void addToWishlist(CartItem item) {
    if (!wishlist.any((e) => e.name == item.name)) {
      wishlist.add(item);
    }
  }

  void removeFromWishlist(String itemName) {
    wishlist.removeWhere((item) => item.name == itemName);
  }
}
