import 'package:dio/dio.dart';
import 'token_service.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://124.123.30.75:8001/",
       headers: {
    "Content-Type": "application/json",
    "accept": "application/json",
    "ngrok-skip-browser-warning": "true",
  },
      ),
    );

    // ✅ Interceptor for token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenService.getToken();

          options.headers["Authorization"] = "Bearer $token";
        
          return handler.next(options);
        },
      ),
    );
  }

  ////////////////////////////////////////////////
  /// GET
  ////////////////////////////////////////////////
  Future<Response> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return await dio.get(path, queryParameters: query);
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return await dio.post(path, data: data);
  }

  ////////////////////////////////////////////////
  /// PUT
  ////////////////////////////////////////////////
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return await dio.put(path, data: data);
  }

  ////////////////////////////////////////////////
  /// DELETE
  ////////////////////////////////////////////////
  Future<Response> delete(
    String path,
  ) async {
    return await dio.delete(path);
  }
}