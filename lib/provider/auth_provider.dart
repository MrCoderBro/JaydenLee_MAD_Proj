import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'user_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(UserProvider userProvider, String email, String password) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    Map<String, dynamic>? user = await dbHelper.getUser(email, password);
    if (user != null) {
      _isAuthenticated = true;
      userProvider.setUserId(user['id']);
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<void> register(String email, String password, String phoneNumber) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    bool emailExists = await dbHelper.emailExists(email);
    if (emailExists) {
      throw Exception("Email already exists");
    }
    Map<String, dynamic> user = {
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    };
    await dbHelper.insertUser(user);
  }

  void logout(UserProvider userProvider) {
    _isAuthenticated = false;
    userProvider.clearUserId();
    notifyListeners();
  }
}