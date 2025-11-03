import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  final Map<String, Map<String, String>> translations;

  AppTranslations(this.translations);

  @override
  Map<String, Map<String, String>> get keys => translations;
}

Future<Map<String, Map<String, String>>> loadTranslations() async {
  final Map<String, Map<String, String>> translations = {};
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final translationFiles = manifestMap.keys
      .where((String key) => key.startsWith('assets/translations/'))
      .toList();

  for (String file in translationFiles) {
    // Lấy mã ngôn ngữ từ tên file, ví dụ: 'en' từ 'en.json' hoặc 'pt_BR' từ 'pt_BR.json'
    String langCode = file.split('/').last.replaceAll('.json', '');
    String content = await rootBundle.loadString(file);
    translations[langCode] = Map<String, String>.from(json.decode(content));
  }
  return translations;
}
