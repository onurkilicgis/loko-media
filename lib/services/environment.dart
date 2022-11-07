import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get env {
    if (kReleaseMode) {
      return 'assets/.env.production';
    }
    return 'assets/.env.development';
  }

  static String? get dbname {
    return dotenv.env['DB_NAME'] ?? 'DB_NAME not found!';
  }

  static String? get apiUrl {
    return dotenv.env['API_URL'] ?? 'false';
  }
}
