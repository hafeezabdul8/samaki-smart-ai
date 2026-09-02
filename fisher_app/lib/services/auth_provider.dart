import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _user;
  bool _loading = false;

  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _api.token != null;
  String? get token => _api.token;

  Future<void> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _api.login(username, password);
      _user = await _api.getProfile();
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(
      String username, String phone, String password, String role,
      {String? securityQuestion, String? securityAnswer}) async {
    _loading = true;
    notifyListeners();
    try {
      await _api.register(username, phone, password, role,
          securityQuestion: securityQuestion, securityAnswer: securityAnswer);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  void logout() {
    _api.token = null;
    _user = null;
    notifyListeners();
  }
}