import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio;
    ApiClient()
    : _dio = Dio(
        BaseOptions(
          //baseUrl: 'http://192.168.1.43/findup.yornvichet.online/public/api/', // local
          baseUrl: "https://findup.yornvichet.online/api/",  // server
         
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  _dio.interceptors.clear();

  }

  // 🔵 Universal POST (handles both FormData and JSON)
  Future<Response> post(String endpoint, dynamic data) async {

    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final options = Options(
        headers: {
          'Content-Type': (data is FormData)
              ? 'multipart/form-data'
              : 'application/json',
          'Accept': 'application/json',
        },
      );

      final response = await _dio.post(endpoint, data: data, options: options);
      return response;
    } on DioError catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // 🧩 Error handler
  String _handleError(DioError error) {
    if (error.response != null) {
      return 'Error ${error.response?.statusCode}: ${error.response?.data}';
    } else {
      return 'Network Error: ${error.message}';
    }
  }

  // 🟡 POST request (used for login or any endpoint)

  /// 🔐 Save token after login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 🧹 Remove token (for logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _dio.options.headers.remove('Authorization');
  }
}
