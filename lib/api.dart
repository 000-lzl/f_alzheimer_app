import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode

class ApiService {
  static const String baseUrl = 'http://himhealth.mcu.edu.tw:8048';

  // 模擬開關：true = 用假資料，false = 打真實後端
  final bool useMock;

  late final Dio _dio;
  String? _token;

  ApiService({this.useMock = true}) {  // 預設用模擬模式
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

  Future<Map<String, dynamic>> login(String account, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1)); // 模擬網路延遲
      print('【模擬】登入成功：$account');
      return {
        'id': 1001,
        'account': account,
        'name': '測試使用者',
        'birthday': '2000-01-01',
        'height': 170.0,
        'weight': 60.0,
        'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      };
    }

    // 真實 API
    final response = await _dio.post('/auth/login', data: {
      'account': account,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data['user'] as Map<String, dynamic>;
  }

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
      print('【模擬】註冊成功：$name ($account)');
      return {
        'id': 1002,
        'account': account,
        'name': name,
        'birthday': birthday,
        'height': height,
        'weight': weight,
        'token': 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      };
    }

    // 真實 API
    final response = await _dio.post('/auth/register', data: {
      'account': account,
      'password': password,
      'name': name,
      'birthday': birthday,
      'height': height,
      'weight': weight,
    });
    final data = response.data as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      print('【模擬】取得個人資料');
      return {
        'id': 1001,
        'account': 'test123',
        'name': '測試使用者',
        'birthday': '2000-01-01',
        'height': 170.0,
        'weight': 60.0,
      };
    }

    // 真實 API（自動帶 token）
    final response = await _dio.get('/users/me');
    return response.data as Map<String, dynamic>;
  }

// 未來其他 API 方法也可以用同樣方式加模擬
}

/*
class ApiService {
  static const String baseUrl = 'http://himhealth.mcu.edu.tw:8048/v1/predict';
  late final Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // 全局攔截器（加 token、處理錯誤）
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        if (kDebugMode) {
          print('→ ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('← ${response.statusCode} ${response.realUri}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // 這裡可以統一處理 401 → 登出、403 → 權限錯誤 等
        String msg = e.response?.data?['message'] ?? e.message ?? '網路錯誤';
        if (e.response?.statusCode == 401) {
          // 可觸發登出邏輯
        }
        return handler.next(e);
      },
    ));
  }

  void setToken(String? token) => _token = token;

  // ────────────── Auth ──────────────
  Future<Map<String, dynamic>> login(String account, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'account': account,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String account,
    required String password,
    required String name,
    required String birthday, // yyyy-MM-dd
    required double height,
    required double weight,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'account': account,
      'password': password,
      'name': name,
      'birthday': birthday,
      'height': height,
      'weight': weight,
    });
    final data = response.data as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data['user'] as Map<String, dynamic>;
  }

  // ────────────── Profile ──────────────
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/users/me'); // 或 /profile
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    await _dio.put('/users/me', data: updates);
  }

  // ────────────── Game Records ──────────────
  Future<void> saveGameRecord({
    required String gameType, // memory_flip, stroop, puzzle
    required int score,
    int? seconds,
    int? level,
  }) async {
    await _dio.post('/games/$gameType/records', data: {
      'score': score,
      'seconds': seconds,
      'level': level,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<dynamic>> getGameHistory(
      String gameType, {
        int limit = 20,
        String sort = 'desc',
      }) async {
    final response = await _dio.get(
      '/games/$gameType/records',
      queryParameters: {'limit': limit, 'sort': sort},
    );
    return response.data as List<dynamic>;
  }
}
*/
