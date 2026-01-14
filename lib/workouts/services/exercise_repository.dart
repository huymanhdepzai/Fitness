import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/exercise_model.dart';

class ExerciseRepository {
  static const _assetPath = 'assets/data/exercises_data.json';
  static const _fileName = 'exercises_data.json';

  static List<ExerciseModel>? _memoryCache;

  Future<List<ExerciseModel>> loadAllOnce() async {
    // cache in-memory: trong 1 phiên chạy app chỉ parse 1 lần
    final cached = _memoryCache;
    if (cached != null) return cached;

    final jsonStr = await _readJsonString();
    final raw = json.decode(jsonStr);

    if (raw is! List) {
      _memoryCache = <ExerciseModel>[];
      return _memoryCache!;
    }

    _memoryCache = raw
        .whereType<Map>()
        .map((e) => ExerciseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return _memoryCache!;
  }

  Future<String> _readJsonString() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      return file.readAsString();
    }
    // fallback (trường hợp seed chưa chạy)
    return rootBundle.loadString(_assetPath);
  }
}
