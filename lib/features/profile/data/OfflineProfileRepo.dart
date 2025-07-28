import 'dart:convert';

import 'package:recipe_app/features/profile/domain/entities/profile_user.dart';
import 'package:recipe_app/features/profile/domain/repos/profile_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineProfileRepo implements ProfileRepo {
  static const String _key = 'offline_profile_user';

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    return ProfileUser.fromJson(json.decode(jsonString));
  }

  @override
  Future<void> updateProfile(ProfileUser updateProfile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(updateProfile.tojson()));
  }

  Future<void> saveUser(ProfileUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(user.tojson()));
  }
}
