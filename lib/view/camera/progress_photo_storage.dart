import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPhotoItem {
  final String id; // unique
  final DateTime dateTime; // thời điểm chụp/chọn
  final String filePath; // path file local

  ProgressPhotoItem({
    required this.id,
    required this.dateTime,
    required this.filePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'filePath': filePath,
  };

  static ProgressPhotoItem fromJson(Map<String, dynamic> j) {
    return ProgressPhotoItem(
      id: (j['id'] ?? '').toString(),
      dateTime: DateTime.tryParse((j['dateTime'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      filePath: (j['filePath'] ?? '').toString(),
    );
  }
}

class ProgressPhotoStorage {
  static const _kKey = 'progress_photos_v1';

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static Future<List<ProgressPhotoItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<dynamic>();
      final items = list
          .map((e) => ProgressPhotoItem.fromJson(
          (e as Map).cast<String, dynamic>()))
          .toList();

      // lọc những file đã bị xoá khỏi máy
      final filtered = <ProgressPhotoItem>[];
      for (final it in items) {
        if (it.filePath.isNotEmpty && File(it.filePath).existsSync()) {
          filtered.add(it);
        }
      }
      filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first
      return filtered;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<ProgressPhotoItem> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_kKey, raw);
  }

  static Future<String> _photosDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final p = Directory('${dir.path}/progress_photos');
    if (!await p.exists()) {
      await p.create(recursive: true);
    }
    return p.path;
  }

  /// Copy file ảnh được chọn/chụp vào thư mục app, trả về path mới.
  static Future<String> saveImageFileToLocal(File src, DateTime time) async {
    final folder = await _photosDir();
    String two(int x) => x.toString().padLeft(2, '0');
    final ts =
        '${time.year}${two(time.month)}${two(time.day)}_${two(time.hour)}${two(time.minute)}${two(time.second)}';
    final ext = src.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final dstPath = '$folder/$ts.$ext';

    final dst = await src.copy(dstPath);
    return dst.path;
  }

  static Future<ProgressPhotoItem> addPhoto({
    required DateTime dateTime,
    required String filePath,
  }) async {
    final items = await load();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final newItem = ProgressPhotoItem(
      id: id,
      dateTime: dateTime,
      filePath: filePath,
    );

    items.insert(0, newItem);
    await _save(items);
    return newItem;
  }

  static Future<void> deletePhoto(ProgressPhotoItem item) async {
    final items = await load();
    items.removeWhere((e) => e.id == item.id);
    await _save(items);

    // xoá file ảnh luôn
    try {
      final f = File(item.filePath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Map<DateTime, List<ProgressPhotoItem>> groupByDay(
      List<ProgressPhotoItem> items) {
    final Map<DateTime, List<ProgressPhotoItem>> map = {};
    for (final it in items) {
      final d = dateOnly(it.dateTime);
      map.putIfAbsent(d, () => []).add(it);
    }

    // sort each group newest first
    for (final k in map.keys) {
      map[k]!.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    return map;
  }

  /// Tìm cặp so sánh:
  /// - newest: ảnh mới nhất
  /// - older: ảnh gần nhất nhưng phải <= newest - 7 ngày
  static ({ProgressPhotoItem newest, ProgressPhotoItem older})? findComparePair(
      List<ProgressPhotoItem> items) {
    if (items.length < 2) return null;
    final newest = items.first; // vì load() đã sort newest first
    final threshold = newest.dateTime.subtract(const Duration(days: 7));

    ProgressPhotoItem? candidate;
    for (final it in items.skip(1)) {
      if (!it.dateTime.isAfter(threshold)) {
        candidate = it;
        break;
      }
    }
    if (candidate == null) return null;
    return (newest: newest, older: candidate);
  }
}
