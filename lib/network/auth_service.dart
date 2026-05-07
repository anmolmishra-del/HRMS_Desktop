import 'dart:convert';

import 'package:hrms_desktop/network/api_exceptions.dart';
import 'package:hrms_desktop/storage/secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> get(String url) async {
    return _request(
      () async => http.get(Uri.parse(url), headers: await _headers()),
    );
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    return _request(
      () async => http.post(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    final response = await call();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    throw ServerException("Server error (${response.statusCode})");
  }

  Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}
