import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode

class ApiService {
  static const String baseUrl = 'http://himhealth.mcu.edu.tw:8048';


  final bool useMock;

  late final Dio _dio;
  String? _token;

  ApiService({this.useMock = false}) {
    // 預設用模擬模式
    // 模擬開關：true = 用假資料，false = 打真實後端
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
    ));
  }

  void setToken(String? token) {
    _token = token;
  }

  // 登入：POST /auth/login
  Future<Map<String, dynamic>> login(String account, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'account': account,
        'name': '測試使用者',
        'birthday': '2000-01-01',
        'height': 170.0,
        'weight': 60.0,
        'token': 'mock-jwt-token-xxx',
      };
    }

    try {
      final response = await _dio.post('/auth/login', data: {
        'account': account,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      //_token = data['token'] as String?;
      return data;  // 假設回傳包含 user 與 token
    } on DioException catch (e) {
      print('登入失敗：${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  // 註冊：POST /auth/register
  Future<Map<String, dynamic>> register({
    required String account,
    required String password,
    required String name,
    required String birthday,
    required double height,
    required double weight,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'account': account,
        'name': name,
        'birthday': birthday,
        'height': height,
        'weight': weight,
        'token': 'mock-jwt-token-xxx',
      };
    }

    try {
      final response = await _dio.post('/auth/register', data: {
        'account': account,
        'password': password,
        'name': name,
        'birthday': birthday,
        'height': height,
        'weight': weight,
      });

      final data = response.data as Map<String, dynamic>;

      return data;
    } on DioException catch (e) {
      print('註冊失敗：${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  // 取得個人資料：改成 POST /users/me（後端是 POST！）
  Future<Map<String, dynamic>> getProfile() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'account': 'test123',
        'name': '測試使用者',
        'birthday': '2000-01-01',
        'height': 170.0,
        'weight': 60.0,
      };
    }

    try {
      final response = await _dio.post('/users/me');  // ← 改成 POST
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('取得個人資料失敗：${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 405) {
        print('警告：後端 /users/me 只允許 POST 方法，但你用了 GET');
      }
      rethrow;
    }
  }

  // 遊戲歷史紀錄：POST /games/history（後端是 POST）
  Future<List<Map<String, dynamic>>> getGameHistory(String gameType) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return List.generate(5, (i) => {
        'score': 80 + i * 5,
        'seconds': 120 - i * 10,
        'level': 3 + i,
        'playedAt': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
      });
    }

    try {
      final response = await _dio.post('/games/history', data: {
        'gameType': gameType,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('取得遊戲歷史失敗：${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }
}

// 未來其他 API 方法也可以用同樣方式加模擬

