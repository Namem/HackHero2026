import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _parse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    String message = 'Erro desconhecido';
    try {
      final err = jsonDecode(body);
      message = err['detail'] ?? err['message'] ?? err.toString();
    } catch (_) {
      message = body;
    }
    throw ApiException(response.statusCode, message);
  }

  static Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http
        .get(uri, headers: await _headers(auth: auth))
        .timeout(ApiConfig.timeout);
    return _parse(response);
  }

  static Future<List<dynamic>> getList(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http
        .get(uri, headers: await _headers(auth: auth))
        .timeout(ApiConfig.timeout);
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body) as List<dynamic>;
    }
    throw ApiException(response.statusCode, body);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http
        .post(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _parse(response);
  }

  /// POST que aceita resposta de qualquer formato (Map ou List).
  /// Use quando o backend retorna uma lista pura em vez de objeto.
  static Future<dynamic> postRaw(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http
        .post(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    final raw = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(raw);
    }
    String message = 'Erro desconhecido';
    try {
      final err = jsonDecode(raw);
      message = err is Map ? (err['detail'] ?? err['message'] ?? err.toString()) : raw;
    } catch (_) {
      message = raw;
    }
    throw ApiException(response.statusCode, message);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http
        .put(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _parse(response);
  }

  static Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http
        .delete(uri, headers: await _headers(auth: auth))
        .timeout(ApiConfig.timeout);

    // 204 No Content — retorna mapa vazio em vez de tentar dar parse no body vazio
    if (response.statusCode == 204) {
      return {};
    }

    // Sucesso com body vazio (200/201 sem content) — também trata
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body.isEmpty) {
      return {};
    }

    return _parse(response);
  }
}
