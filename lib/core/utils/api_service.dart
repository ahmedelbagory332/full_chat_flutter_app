import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ApiService {
  final _baseUrl = 'https://fluttertest288.000webhostapp.com/';
  final Dio _dio;

  ApiService(this._dio);

  Future<ApiData> post(
      {required String endPoint, required FormData rawData}) async {
    var response = await _dio.post(
      '$_baseUrl$endPoint',
      data: rawData,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (200 <= response.statusCode! && response.statusCode! <= 300) {
      debugPrint("bego response: ${response.data}");

      return ApiData(
          data: json.decode(response.data),
          code: response.statusCode ?? 0,
          errorMessage: "",
          success: true);
    } else {
      return ApiData(
          data: json.decode(response.data),
          code: response.statusCode ?? 0,
          errorMessage: "something went wrong",
          success: false);
    }
  }
}

class ApiData {
  final Map<String, dynamic> data;
  final int code;
  final String errorMessage;
  final bool success;

  const ApiData(
      {required this.data,
      required this.code,
      required this.errorMessage,
      required this.success});

  ApiData copyWith({
    Map<String, dynamic>? data,
    int? code,
    String? errorMessage,
    bool? success,
  }) {
    return ApiData(
      data: data ?? this.data,
      code: code ?? this.code,
      errorMessage: errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }
}
