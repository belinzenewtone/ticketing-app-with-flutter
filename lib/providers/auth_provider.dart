import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/auth_storage.dart';
import '../models/user.dart';

// ---------------------------------------------------------------------------
// Auth State
// ---------------------------------------------------------------------------
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ---------------------------------------------------------------------------
// Auth Notifier
// ---------------------------------------------------------------------------
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthInitial());

  Future<void> init() async {
    state = const AuthLoading();
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        state = const AuthInitial();
        return;
      }
      final resp = await ApiClient.instance.get('/api/mobile/me');
      final user = User.fromJson(resp.data as Map<String, dynamic>);
      await AuthStorage.saveUser(user);
      state = AuthAuthenticated(user);
    } catch (_) {
      await AuthStorage.clear();
      state = const AuthInitial();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final resp = await ApiClient.instance.post(
        '/api/mobile/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = resp.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      await AuthStorage.saveToken(token);
      await AuthStorage.saveUser(user);
      state = AuthAuthenticated(user);
    } on DioException catch (e) {
      state = AuthError(ApiException.fromDio(e).message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> updateUser(User updated) async {
    await AuthStorage.saveUser(updated);
    state = AuthAuthenticated(updated);
  }

  Future<void> logout() async {
    await AuthStorage.clear();
    state = const AuthInitial();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
