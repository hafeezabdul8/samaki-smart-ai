import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  static const String baseUrl = 'https://samaki-smart-ai.onrender.com/api/auth';

  String? token;

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      token = data['access'];
      return data;
    }
    throw Exception('Login failed');
  }

  Future<Map<String, dynamic>> register(
      String username, String phone, String password, String role,
      {String? securityQuestion, String? securityAnswer}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'phone': phone,
        'password': password,
        'role': role,
        if (securityQuestion != null && securityQuestion.isNotEmpty) 'security_question': securityQuestion,
        if (securityAnswer != null && securityAnswer.isNotEmpty) 'security_answer': securityAnswer,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body).toString());
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load profile');
  }

  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? location,
    String? market,
    String? hotelName,
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    final body = <String, dynamic>{};
    if (phone != null) body['phone'] = phone;
    if (location != null) body['location'] = location;
    if (market != null) body['market'] = market;
    if (hotelName != null) body['hotel_name'] = hotelName;
    if (securityQuestion != null) body['security_question'] = securityQuestion;
    if (securityAnswer != null) body['security_answer'] = securityAnswer;

    final res = await http.patch(
      Uri.parse('$baseUrl/profile/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update profile');
  }

  Future<List<dynamic>> getPrices() async {
    final res = await http.get(Uri.parse('$baseUrl/prices/'));
    if (res.statusCode == 200) return jsonDecode(res.body)['results'];
    throw Exception('Failed to load prices');
  }

  Future<List<dynamic>> getAlerts() async {
    final res = await http.get(Uri.parse('$baseUrl/alerts/'));
    if (res.statusCode == 200) return jsonDecode(res.body)['results'];
    throw Exception('Failed to load alerts');
  }

  Future<List<dynamic>> getForecast(String species, String market) async {
    final res = await http.post(
      Uri.parse('$baseUrl/forecast/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'species': species,
        'market': market,
        'avg_quantity': 15,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load forecast');
  }

  Future<List<dynamic>> getOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['results'];
    throw Exception('Failed to load orders');
  }

  Future<List<dynamic>> getOrderHistory(String period) async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/history/?period=$period'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['results'];
    throw Exception('Failed to load order history');
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/orders/$orderId/status/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) throw Exception('Failed to update order');
  }

  Future<void> registerDeviceToken(String fcmToken) async {
    final res = await http.post(
      Uri.parse('$baseUrl/device-token/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );
    if (res.statusCode == 200) {
      debugPrint('Device token registered');
    }
  }

  Future<Map<String, dynamic>> getChatMessages(int orderId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/chat/orders/$orderId/messages/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load messages');
  }

  Future<Map<String, dynamic>> sendMessage(int orderId, String message) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/orders/$orderId/send/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message}),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to send message');
  }

  // Product endpoints
  Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/products/'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['results'] ?? data;
    }
    throw Exception('Failed to load products');
  }

  Future<List<dynamic>> getMyProducts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/products/my/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['results'] ?? data;
    }
    throw Exception('Failed to load my products');
  }

  Future<Map<String, dynamic>> createProduct({
    required int speciesId,
    required String photoUrl,
    required double pricePerKg,
    required double quantityKg,
    required String market,
    String? description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/products/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'species': speciesId,
        'photo_url': photoUrl,
        'price_per_kg': pricePerKg.toString(),
        'quantity_kg': quantityKg.toString(),
        'market': market,
        'description': description ?? '',
        'expires_at': DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10),
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to create product: ${res.body}');
  }

  Future<Map<String, dynamic>> uploadProductPhoto(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products/upload-photo/'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to upload photo: ${response.body}');
  }

  Future<Map<String, dynamic>> orderProduct(int productId, {double? quantityKg, String? deliveryDate}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/products/$productId/order/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (quantityKg != null) 'quantity_kg': quantityKg.toString(),
        if (deliveryDate != null) 'delivery_date': deliveryDate,
      }),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Failed to order product: ${res.body}');
  }

  Future<Map<String, dynamic>> updateProduct(int productId, {
    double? pricePerKg,
    double? quantityKg,
    String? market,
    String? description,
  }) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/products/$productId/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (pricePerKg != null) 'price_per_kg': pricePerKg.toString(),
        if (quantityKg != null) 'quantity_kg': quantityKg.toString(),
        if (market != null) 'market': market,
        if (description != null) 'description': description,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update product: ${res.body}');
  }

  Future<void> deleteProduct(int productId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/products/$productId/update/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed to delete product: ${res.body}');
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String username) async {
    final res = await http.post(
      Uri.parse('$baseUrl/forgot-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'User not found');
  }

  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String answer,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reset-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'answer': answer,
        'new_password': newPassword,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'Reset failed');
  }

    // Payment endpoints
  Future<Map<String, dynamic>> generatePayment(int orderId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 201 || res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to generate payment: ${res.body}');
  }

  Future<Map<String, dynamic>> uploadReceipt(int orderId, File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/orders/$orderId/payment/receipt/'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to upload receipt: ${response.body}');
  }

  Future<Map<String, dynamic>> approvePayment(int orderId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment/approve/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to approve payment: ${res.body}');
  }

  Future<Map<String, dynamic>> rejectPayment(int orderId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment/reject/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to reject payment: ${res.body}');
  }

  Future<Map<String, dynamic>> assignDelivery(
    int orderId, {
    required String deliveryPersonName,
    required String deliveryPersonPhone,
    required String estimatedTime,
    required String meetingArea,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/delivery/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'delivery_person_name': deliveryPersonName,
        'delivery_person_phone': deliveryPersonPhone,
        'estimated_time': estimatedTime,
        'meeting_area': meetingArea,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to assign delivery: ${res.body}');
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/details/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get order details: ${res.body}');
  }
}