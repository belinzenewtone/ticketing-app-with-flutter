import 'package:dio/dio.dart';
import 'auth_storage.dart';
import 'constants.dart';

class ApiClient {
  static final Dio _dio = _createDio();

  static Dio get instance => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await AuthStorage.clear();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    String msg = 'An error occurred';
    if (data is Map && data['error'] != null) {
      msg = data['error'].toString();
    } else if (data is Map && data['message'] != null) {
      msg = data['message'].toString();
    } else if (e.message != null) {
      msg = e.message!;
    }
    return ApiException(msg, statusCode: e.response?.statusCode);
  }

  @override
  String toString() => message;
}
