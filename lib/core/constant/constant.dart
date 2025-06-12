




import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class AppStrings {
  static late String urlApi;
}

Future<String> getApiUrl() async {
  final String jsonString = await rootBundle.loadString('assets/config.json');
  final Map<String, dynamic> config = jsonDecode(jsonString);
  return config['api_url'];
}

class ConfigLoader {
  static late Map<String, dynamic> config;

  static Future<Map<String, dynamic>> loadConfig() async {
    final String jsonString = await rootBundle.loadString('assets/config.json');
    config = json.decode(jsonString);
    return config;
  }
}

bool isWeb() => kIsWeb;
bool isMobile() => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
bool isDesktop() => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux);