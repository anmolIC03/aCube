import 'dart:convert';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WishlistController extends GetxController {
  var wishlist = <CartItem>[].obs;

  final storage = GetStorage();
  final String storageKey = 'wishlist';

  @override
  void onInit() {
    super.onInit();
    loadWishlistFromStorage();
  }

  void loadWishlistFromStorage() {
    final data = storage.read(storageKey);
    if (data != null) {
      final List decoded = json.decode(data);
      final loadedWishlist = decoded.map((e) => CartItem.fromJson(e)).toList();
      wishlist.assignAll(loadedWishlist);
    }
  }

  void saveWishlistToStorage() {
    final List jsonList = wishlist.map((e) => e.toJson()).toList();
    storage.write(storageKey, json.encode(jsonList));
  }

  void addToWishlist(CartItem item) {
    if (!wishlist.any((e) => e.name == item.name)) {
      wishlist.add(item);
      saveWishlistToStorage();
    }
  }

  void removeFromWishlist(String itemName) {
    wishlist.removeWhere((item) => item.name == itemName);
    saveWishlistToStorage();
  }

  bool isInWishlist(String itemName) {
    return wishlist.any((item) => item.name == itemName);
  }
}
