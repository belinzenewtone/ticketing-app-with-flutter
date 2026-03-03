import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'constants.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: kTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: kTokenKey);
  }

  static Future<void> saveUser(User user) async {
    await _storage.write(key: kUserKey, value: jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final raw = await _storage.read(key: kUserKey);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
