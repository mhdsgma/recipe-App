import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:recipe_app/features/auth/domain/entities/app_user.dart';
import 'package:recipe_app/features/auth/domain/repos/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineAuthRepo implements AuthRepo {
  static const String _currentUserKey = 'CURRENT_USER';

  final List<AppUser> _users = [
    AppUser(
      uid: 'u001',
      email: 'test@test.com',
      name: 'Test User',
      password: '123456',
    ),
  ];

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    final user = _users.firstWhereOrNull(
      (u) => u.email == email && (u.password == null || u.password == password),
    );

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    }

    return user;
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    if (_users.any((u) => u.email == email)) return null;

    final newUser = AppUser(
      uid: 'u${_users.length + 1}'.padLeft(4, '0'),
      email: email,
      name: name,
      password: password.isNotEmpty ? password : null,
    );

    _users.add(newUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));

    return newUser;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_currentUserKey);
    if (json == null) return null;
    return AppUser.fromJson(jsonDecode(json));
  }
}
