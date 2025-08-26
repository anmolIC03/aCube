// lib/services/order_services.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acu/models/ordermodel.dart';

class OrderService {
  /// This still works for one-time fetch
  static Future<List<Order>> fetchUserOrders(String userId) async {
    final url =
        Uri.parse('https://backend.acubemart.in/api/order/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);

      if (jsonMap['success'] == true && jsonMap['data'] is List) {
        final List<dynamic> dataList = jsonMap['data'];
        final orders = dataList.map((json) => Order.fromJson(json)).toList();
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      } else {
        throw Exception("Unexpected data format: ${jsonMap['message']}");
      }
    } else {
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
  }

  /// This creates a stream that fetches orders periodically
  static Stream<List<Order>> streamUserOrders(String userId,
      {Duration interval = const Duration(seconds: 10)}) async* {
    while (true) {
      try {
        final orders = await fetchUserOrders(userId);
        yield orders;
      } catch (e) {
        yield* Stream.error(e);
      }

      await Future.delayed(interval);
    }
  }
}
