import 'package:acu/models/product_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  String apiUrl = "https://backend.acubemart.in/api/product/all";

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    try {
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(jsonEncode(jsonData));
        List<Product> products = (jsonData['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception("Server returned status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error details: $e");
      throw Exception("Failed to load products: $e");
    }
  }
}

class CategoryApiService {
  static const String baseUrl = "https://backend.acubemart.in/api";

  /// Generic GET request method
  static Future<dynamic> get(String endpoint) async {
    final String url = '$baseUrl$endpoint';

    try {
      print("API Call: $url");
      final response = await http.get(Uri.parse(url));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("API Error: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("API Request Failed: $e");
      return {};
    }
  }

  static Future<List<Map<String, String>>> fetchTypes() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend.acubemart.in/api/type/all'));

      print("API Call: ${response.request?.url}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Full response

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);

        if (decoded is Map && decoded.containsKey("type")) {
          List<dynamic> types = decoded["type"];

          return types
              .map((t) =>
                  {"id": t["_id"].toString(), "name": t["name"].toString()})
              .toList();
        } else {
          print("Unexpected API response format.");
          return [];
        }
      } else {
        print("Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("API request failed: $e");
      return [];
    }
  }

  // Fetch all categories and store both ID & name
  static Future<List<Map<String, String>>> fetchCategories() async {
    final url = "$baseUrl/category/all";
    print("Fetching categories from: $url");

    final response = await http.get(Uri.parse(url));

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<Map<String, String>> categories = (jsonData['data'] as List)
              .map((item) => {
                    "id": item["_id"]?.toString() ?? "", // Store _id
                    "name": item["name"]?.toString() ?? "" // Store name
                  })
              .where(
                  (item) => item["id"]!.isNotEmpty && item["name"]!.isNotEmpty)
              .toList();

          return categories;
        } else {
          print("Invalid response format: ${response.body}");
          throw Exception("Invalid API response format");
        }
      } catch (e) {
        print("Error parsing categories: $e");
        throw Exception("Failed to parse categories: $e");
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  // Fetch category details using category ID
  static Future<Map<String, dynamic>> fetchCategoryById(
      String categoryId) async {
    final url = "$baseUrl/category/$categoryId"; // Use ID instead of name
    print("Fetching category: $url");

    final response = await http.get(Uri.parse(url));

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['data'];
    } else {
      throw Exception("Failed to load category details");
    }
  }

  static Future<List<dynamic>> fetchProductsByCategoryId(
      String categoryId, int page, int limit) async {
    print("Fetching products for category: $categoryId | Page: $page");

    var response = await CategoryApiService.get('/product/all');

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      List<dynamic> allProducts = response['data'];

      // ✅ Filter products based on categoryId
      List<dynamic> filteredProducts = allProducts.where((product) {
        var categories = product['category'];
        if (categories is List) {
          return categories.any((cat) => cat['_id'] == categoryId);
        }
        return false;
      }).toList();

      // ✅ Pagination Logic
      int startIndex = (page - 1) * limit;
      int endIndex = startIndex + limit;

      if (startIndex >= filteredProducts.length) {
        return []; // No more products available
      }

      List<dynamic> paginatedProducts = filteredProducts.sublist(
          startIndex, endIndex.clamp(0, filteredProducts.length));

      print("Returning ${paginatedProducts.length} products");
      return paginatedProducts;
    }

    return [];
  }
}
