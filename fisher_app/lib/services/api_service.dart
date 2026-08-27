import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your PC's IP when running on phone
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
      String username, String phone, String password, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'phone': phone,
        'password': password,
        'role': role,
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
  }) async {
    final body = <String, dynamic>{};
    if (phone != null) body['phone'] = phone;
    if (location != null) body['location'] = location;
    if (market != null) body['market'] = market;
    if (hotelName != null) body['hotel_name'] = hotelName;

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
}