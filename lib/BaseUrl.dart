// base_url.dart
import 'dart:io';

class BaseUrl {
  static String get baseUrl {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://10.0.2.2:3000'; // Emulator address
    } else {
      return 'http://localhost:3000'; // Localhost for non-emulator environments
    }
  }
}
