import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tasksKey = 'tasks';
  static const String _gradesKey = 'grades';
  static const String _achievementsKey = 'achievements';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Tasks
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final String tasksJson = jsonEncode(tasks);
    await _prefs.setString(_tasksKey, tasksJson);
  }

  List<Map<String, dynamic>> getTasks() {
    final String? tasksJson = _prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
  }

  // Grades
  Future<void> saveGrades(List<Map<String, dynamic>> grades) async {
    final String gradesJson = jsonEncode(grades);
    await _prefs.setString(_gradesKey, gradesJson);
  }

  List<Map<String, dynamic>> getGrades() {
    final String? gradesJson = _prefs.getString(_gradesKey);
    if (gradesJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(gradesJson));
  }

  // Achievements
  Future<void> saveAchievements(List<Map<String, dynamic>> achievements) async {
    final String achievementsJson = jsonEncode(achievements);
    await _prefs.setString(_achievementsKey, achievementsJson);
  }

  List<Map<String, dynamic>> getAchievements() {
    final String? achievementsJson = _prefs.getString(_achievementsKey);
    if (achievementsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(achievementsJson));
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
