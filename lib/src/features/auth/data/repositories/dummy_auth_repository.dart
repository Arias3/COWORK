import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryLocal implements IAuthRepository {
  final List<Map<String, dynamic>> _preloadedUsers = [
    {
      "email": "a@a.com",
      "password": "123456",
      "role": "teacher",
      "courses": ["curso1"],
    },
    {
      "email": "b@b.com",
      "password": "123456",
      "role": "student",
      "courses": ["curso1"],
    },
    {
      "email": "c@c.com",
      "password": "123456",
      "role": "student",
      "courses": [],
    },
  ];

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('users')) {
      await prefs.setString('users', jsonEncode(_preloadedUsers));
    }
  }

  @override
  Future<bool> login(AuthenticationUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await _initData();
    final users = List<Map<String, dynamic>>.from(
      jsonDecode(prefs.getString('users')!),
    );

    final found = users.firstWhere(
      (u) => u['email'] == user.email && u['password'] == user.password,
      orElse: () => {},
    );

    return found.isNotEmpty;
  }

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = List<Map<String, dynamic>>.from(
      jsonDecode(prefs.getString('users')!),
    );

    users.add({
      "email": user.email,
      "password": user.password,
      "role": "student",
      "courses": [],
    });

    await prefs.setString('users', jsonEncode(users));
    return true;
  }

  @override
  Future<bool> logOut() async => true;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<bool> validate(String email, String code) async => true;

  @override
  Future<bool> validateToken() async => true;
}
