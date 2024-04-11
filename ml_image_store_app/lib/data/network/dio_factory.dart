import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ml_image_store_app/data/storage/auth_storage.dart';

class DioFactory {
  static const _timeout = Duration(seconds: 30);

  final AuthStorage _authStorage;

  const DioFactory(this._authStorage);

  Dio create() {
    final options = BaseOptions(
      contentType: "application/json",
      connectTimeout: _timeout,
      sendTimeout: _timeout,
      receiveTimeout: _timeout,
    );
    final dio = Dio(options);

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _authStorage.clear();
          }
          handler.next(error);
        },
        onRequest: (options, handler) async {
          final auth = await _authStorage.get();
          if (auth != null) {
            options.headers['Authorization'] = 'Bearer $auth';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => log("$obj"),
        ),
      );
    }

    return dio;
  }
}
