import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Required for accessing DefaultHttpClientAdapter
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
  // Configure SSL/TLS bypass for development
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };

  // Add interceptors for token management and error handling
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
      // Log more detailed information about the error
      print('Dio error occurred: ${error.message}');
      if (error.response != null) {
        print('Status code: ${error.response?.statusCode}');
        print('Response data: ${error.response?.data}');
        print('Headers: ${error.response?.headers}');
      } else {
        print('Error sending request: ${error.message}');
      }
      handler.next(error); // Pass the error to the next handler
    },
  ));
}

Future<void> changePassword() async {
  try {
    final response = await dio.post(
      'http://10.0.2.2:3000/change-password', // Use 10.0.2.2 for Android emulator
      data: {
        'new_password': 'newPassword123',
      },
    );

    print('Response data: ${response.data}');
  } catch (e) {
    if (e is DioError) {
      print('Dio error occurred: ${e.message}');
      if (e.response != null) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
    } else {
      print('General error: $e');
    }
  }
}
