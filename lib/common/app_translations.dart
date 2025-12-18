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

  final AssetManifest manifest =
  await AssetManifest.loadFromAssetBundle(rootBundle);

  final translationFiles = manifest.listAssets().where(
        (String key) => key.startsWith('assets/translations/'),
  );

  for (final file in translationFiles) {
    final langCode = file.split('/').last.replaceAll('.json', '');
    final content = await rootBundle.loadString(file);
    translations[langCode] =
    Map<String, String>.from(json.decode(content));
  }

  return translations;
}

