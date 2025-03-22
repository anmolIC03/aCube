import 'package:acu/models/product_models.dart';
import 'package:acu/services/api_services.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var productList = <Product>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      var apiService = ApiService();
      var products = await apiService.fetchProducts();
      productList.value = products;
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading(false);
    }
  }
}
