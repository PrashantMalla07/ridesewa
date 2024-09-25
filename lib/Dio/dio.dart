import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final Dio dio = Dio();
final FlutterSecureStorage storage = FlutterSecureStorage();

class AuthService {
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }
}
void setupDio() {
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
      final token = await AuthService().getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options); // Pass modified options to the next interceptor
    },
    onResponse: (Response response, ResponseInterceptorHandler handler) {
      handler.next(response); // Pass the response to the next interceptor
    },
    onError: (DioError error, ErrorInterceptorHandler handler) {
      handler.next(error); // Pass the error to the next handler
    },
  ));
}


Future<void> changePassword() async {
  try {
    final response = await dio.post(
      'http://localhost:3000/change-password',
      data: {
        'new_password': 'newPassword123',
      },
    );

    print(response.data);
  } catch (e) {
    print('Error: $e');
  }
}
