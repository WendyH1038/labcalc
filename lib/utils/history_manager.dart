// lib/utils/history_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationRecord {
  final String title;
  final String details;
  final String result;
  final DateTime timestamp;

  CalculationRecord({
    required this.title,
    required this.details,
    required this.result,
    required this.timestamp,
  });

  // Convert a record to a JSON Map to save to disk
  Map<String, dynamic> toJson() => {
    'title': title,
    'details': details,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
  };

  // Create a record back from a JSON Map read from disk
  factory CalculationRecord.fromJson(Map<String, dynamic> json) =>
      CalculationRecord(
        title: json['title'],
        details: json['details'],
        result: json['result'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class HistoryManager {
  static const String _storageKey = 'labcalc_history_records';

  // Save a new record permanently
  static Future<void> addRecord({
    required String title,
    required String details,
    required String result,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<CalculationRecord> currentList = await loadHistory();

    currentList.insert(
      0,
      CalculationRecord(
        title: title,
        details: details,
        result: result,
        timestamp: DateTime.now(),
      ),
    );

    // Keep top 20 items max
    if (currentList.length > 20) {
      currentList = currentList.sublist(0, 20);
    }

    // Encode to JSON strings list and write to local disk
    List<String> encodedList = currentList
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, encodedList);
  }

  // Read all records from local disk
  static Future<List<CalculationRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedList = prefs.getStringList(_storageKey);

    if (encodedList == null) return [];

    return encodedList
        .map((item) => CalculationRecord.fromJson(jsonDecode(item)))
        .toList();
  }

  // Clear disk history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
