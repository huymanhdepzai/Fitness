import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WorkoutNote {
  final String id;
  final int notificationId;
  final DateTime dateTime; // ngày + giờ cụ thể
  final String title;
  final String? description;

  WorkoutNote({
    required this.id,
    required this.notificationId,
    required this.dateTime,
    required this.title,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'dateTime': dateTime.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  factory WorkoutNote.fromJson(Map<String, dynamic> json) {
    return WorkoutNote(
      id: json['id'] as String,
      notificationId: json['notificationId'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }
}

class WorkoutNoteStorage {
  static const _key = 'workout_notes';

  static Future<List<WorkoutNote>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final List list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => WorkoutNote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveNotes(List<WorkoutNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notes.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<void> addNote(WorkoutNote note) async {
    final notes = await loadNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  static Future<void> deleteNote(WorkoutNote note) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n.id == note.id);
    await saveNotes(notes);
  }
  static Future<void> clearAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> clearAllNotesAndCancelNotifications({
    required Future<void> Function(int id) cancelNotification,
  }) async {
    final notes = await loadNotes();

    // Hủy noti cũ
    for (final n in notes) {
      await cancelNotification(n.notificationId);
    }

    // Xóa toàn bộ notes
    await clearAllNotes();
  }
}
