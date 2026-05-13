import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:muslim_mate/utils/logger.dart';

class ApiService {
  final String baseUrl;
  final Duration timeout;

  ApiService({
    this.baseUrl = 'https://api.example.com',
    this.timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final Uri url = Uri.parse('$baseUrl$endpoint');
      Logger.info('GET request to: $url');

      final response = await http.get(url).timeout(timeout);

      if (response.statusCode == 200) {
        Logger.info('GET success: $endpoint');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Logger.error('GET failed: ${response.statusCode} - ${response.body}');
        throw ApiException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('GET error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl$endpoint');
      Logger.info('POST request to: $url with body: $body');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('POST success: $endpoint');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Logger.error('POST failed: ${response.statusCode} - ${response.body}');
        throw ApiException('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('POST error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl$endpoint');
      Logger.info('PUT request to: $url with body: $body');

      final response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        Logger.info('PUT success: $endpoint');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Logger.error('PUT failed: ${response.statusCode} - ${response.body}');
        throw ApiException('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('PUT error: $e');
      rethrow;
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final Uri url = Uri.parse('$baseUrl$endpoint');
      Logger.info('DELETE request to: $url');

      final response = await http.delete(url).timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        Logger.info('DELETE success: $endpoint');
      } else {
        Logger.error('DELETE failed: ${response.statusCode} - ${response.body}');
        throw ApiException('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('DELETE error: $e');
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
