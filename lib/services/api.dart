import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roadmap.dart';
import '../models/stage.dart';

class ApiService {
  static const String _baseUrlKey = 'api_base_url';
  static const String _userIdKey = 'user_id';
  static const String _deviceIdKey = 'device_id';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? 'http://localhost:3000';
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
          DateTime.now().microsecondsSinceEpoch.toRadixString(36);
      await prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String> login() async {
    final baseUrl = await getBaseUrl();
    final deviceId = await _getDeviceId();

    final response = await http.post(
      Uri.parse('$baseUrl/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceId': deviceId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final userId = data['userId'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);

    return userId;
  }

  static Future<Roadmap> generateRoadmap({
    required String ambition,
    required String level,
    required int hoursPerWeek,
  }) async {
    final baseUrl = await getBaseUrl();
    var userId = await getUserId();
    userId ??= await login();

    final response = await http.post(
      Uri.parse('$baseUrl/roadmap'),
      headers: {
        'Content-Type': 'application/json',
        'x-device-id': await _getDeviceId(),
        'x-user-id': userId,
      },
      body: jsonEncode({
        'ambition': ambition,
        'level': level,
        'hoursPerWeek': hoursPerWeek,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to generate roadmap: ${response.body}');
    }

    return Roadmap.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Roadmap?> getActiveRoadmap() async {
    final baseUrl = await getBaseUrl();
    final userId = await getUserId();
    if (userId == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/roadmap/$userId'),
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch roadmap: ${response.body}');
    }

    return Roadmap.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Stage> markStageComplete({
    required String roadmapId,
    required String stageId,
    required bool completed,
  }) async {
    final baseUrl = await getBaseUrl();

    final response = await http.patch(
      Uri.parse('$baseUrl/roadmap/$roadmapId/stage/$stageId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update stage: ${response.body}');
    }

    return Stage.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
