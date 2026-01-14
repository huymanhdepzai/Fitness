import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseBootstrapper {
  static const _seedKey = 'exercises_seeded_v1';
  static const _assetPath = 'assets/data/exercises_data.json';
  static const _fileName = 'exercises_data.json';

  static Future<void> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getBool(_seedKey) ?? false;
    if (seeded) return;

    final jsonStr = await rootBundle.loadString(_assetPath);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    await file.writeAsString(jsonStr, flush: true);
    await prefs.setBool(_seedKey, true);
  }
}
