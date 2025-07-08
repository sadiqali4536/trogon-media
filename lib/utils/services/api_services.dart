import 'dart:convert';
import 'dart:io'; // for SocketException
import 'package:http/http.dart' as http;
import 'package:trogon_media/models/module_model.dart';
import 'package:trogon_media/models/subject_model.dart';
import 'package:trogon_media/models/video_model.dart';

class ApiService {
  static const String _baseUrl = 'https://trogon.info/interview/php/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Fetching subjects from api
  Future<List<SubjectModel>> fetchSubjects() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/subjects.php'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => SubjectModel.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Invalid JSON format');
    } catch (e) {
      throw Exception('Error fetching subjects: $e');
    }
  }

  // Fetching modules from api
  Future<List<ModuleModel>> fetchModules(int subjectId) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/modules.php?subject_id=$subjectId'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ModuleModel.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Invalid JSON format');
    } catch (e) {
      throw Exception('Error fetching modules: $e');
    }
  }

  // Fetching videos from api
  Future<List<VideoModel>> fetchVideos(int moduleId) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/videos.php?module_id=$moduleId'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => VideoModel.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Invalid JSON format');
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
