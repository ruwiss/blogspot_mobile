import 'package:blogman/core/locator.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum HttpMethod { get, put, post, patch, delete }

class HttpService {
  HttpService({this.baseUrl = '', this.responseType, this.contentType})
      : _options = BaseOptions(
          baseUrl: baseUrl,
          responseType: responseType ?? ResponseType.json,
          contentType: contentType ?? Headers.jsonContentType,
        ) {
    _dio = Dio(_options);
  }

  final String baseUrl;

  /// default: ResponseType.json
  final ResponseType? responseType;

  /// default: Headers.jsonContentType
  final String? contentType;
  late final BaseOptions _options;
  late final Dio _dio;
  Map<String, dynamic>? headers;

  // Set Default Headers
  void setDefaultHeaders(Map<String, dynamic> headers) =>
      _dio.options.headers = headers;

  /// Error Count
  int _errorCount = 0;

  Future<Response?> request({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? data,
  }) async {
    // Request method
    final req = switch (method) {
      HttpMethod.get => _dio.get,
      HttpMethod.post => _dio.post,
      HttpMethod.patch => _dio.patch,
      HttpMethod.delete => _dio.delete,
      HttpMethod.put => _dio.put,
    };
    final bool withArgs = method == HttpMethod.get;
    try {
      final response = await req(url,
          data: !withArgs ? data : null,
          queryParameters: withArgs ? data : null);
      return response;
    } on DioException catch (e) {
      _logException(e);

      // Hata olursa 1 kez daha dene
      if (_errorCount == 0) {
        _errorCount++;
        // Kullanıcı OAuth girişini doğrula
        if (await locator<AuthViewModel>().authUser()) {
          return await request(url: url, method: method, data: data);
        } else {
          return null;
        }
      } else {
        // Yeni isteklerde tekrar denemek için değeri sıfırla
        _errorCount = 0;
      }
    }
    return null;
  }

  _logException(DioException e) {
    if (kDebugMode) {
      print("${e.message}");
      if (e.response != null) {
        print("${[e.response!.statusCode]}: ${e.response!.data}");
      }
    }
  }
}
