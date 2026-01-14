import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class UserLocalStorage {
  static const _keyUser = 'app_user';

  // ✅ notifier để screen khác nghe goal thay đổi
  static final ValueNotifier<String?> goalNotifier = ValueNotifier<String?>(null);

  /// Lưu user xuống local dưới dạng JSON
  static Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_keyUser, jsonString);

    // ✅ bắn event khi goal thay đổi
    goalNotifier.value = user.goal;
  }

  /// Lấy user từ local (hoặc null nếu chưa có)
  static Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUser);
    if (jsonString == null) {
      goalNotifier.value = null;
      return null;
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final user = AppUser.fromJson(map);

      // ✅ sync notifier
      goalNotifier.value = user.goal;

      return user;
    } catch (_) {
      goalNotifier.value = null;
      return null;
    }
  }

  /// Xóa user khi logout
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);

    // ✅ reset notifier
    goalNotifier.value = null;
  }
}
