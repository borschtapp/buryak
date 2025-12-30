import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../providers/user.dart';

/// Base URL config
String baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://127.0.0.1:3000/api');

/// Request Query Params
typedef QueryParams = Map<String, dynamic>;

/// Request Body
typedef RequestBody = Map<String, dynamic>;

/// Response Body
typedef ResponseBody = dynamic;

/// Api Header
typedef ApiHeaderType = Map<String, String>;

// Base class for API configuration, containing information such as path, method, authorization, and module.
// The [module] attribute denotes the API's base path, specifying its category.
abstract class Repository {
  RequestMethod method;
  String module;
  String path;
  bool isAuth;

  Repository({
    required this.method,
    required this.module,
    required this.path,
    this.isAuth = true,
  });

  /// to generate full URL
  String getUrlString({String? query}) {
    return '$baseUrl$module$path${query ?? ""}';
  }

  /// redirection
  Future<ResponseBody> sendRequest({QueryParams? queryParams, RequestBody? body, ApiHeaderType? headersCustom}) {
    String query = '';
    if (queryParams != null && queryParams.isNotEmpty) {
      queryParams.forEach((key, value) {
        if (value != null) {
          query += '${query.isEmpty ? '?' : '&'}$key=${Uri.encodeComponent(value)}';
        }
      });
    }
    return RequestHandler.call(getUrlString(query: query), method,
        authorized: isAuth, body: body, headersCustom: headersCustom);
  }
}

enum RequestMethod { get, post, put, delete }

extension MethodManager on RequestMethod {
  Future<http.Response> request(Uri url, {Map<String, String>? headers, Object? body}) async {
    switch (this) {
      case RequestMethod.get:
        return await http.get(url, headers: headers);
      case RequestMethod.post:
        return await http.post(url, headers: headers, body: body);
      case RequestMethod.put:
        return await http.put(url, headers: headers, body: body);
      case RequestMethod.delete:
        return await http.delete(url, headers: headers, body: body);
    }
  }
}

class RequestHandler {
  /// The [urlString] is retrieved from api object.
  /// The [method] is obtained using object.value.method.
  /// For authorized requests, set [authorized] to true.
  /// The [body] parameter stores the request parameters.
  /// The [headersCustom] parameter holds custom header values.
  /// For [RequestMethod.get] and [RequestMethod.delete], append the ID to the [urlString].
  static Future<ResponseBody> call(String urlString, RequestMethod method,
      {bool authorized = true, RequestBody? body, ApiHeaderType? headersCustom}) async {
    try {
      /// set the Headers
      Map<String, String> headers = headersCustom ??
          {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
            if (authorized) HttpHeaders.authorizationHeader: "Bearer ${UserService.getAccessToken()}",
          };

      /// Api call
      final http.Response response =
          await method.request(Uri.parse(urlString), headers: headers, body: json.encode(body));

      final statusType = (response.statusCode / 100).floor() * 100;
      switch (statusType) {
        case 200:
          final responseBody = json.decode(utf8.decode(response.bodyBytes));
          return responseBody;
        case 400:
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          throw handleFormErrors(errorBody);
        case 300:
        case 500:
        default:
          throw GeneralApiException(message: 'Error contacting the server!');
      }
    } catch (e) {
      throw GeneralApiException(message: e.toString());
    }
  }
}

class GeneralApiException implements Exception {
  final String message;

  GeneralApiException({required this.message});

  @override
  String toString() {
    return message;
  }
}

class FieldsApiException extends GeneralApiException {
  final Map<String, dynamic> fields;

  FieldsApiException({
    required super.message,
    required this.fields,
  });

  @override
  String toString() {
    var first = fields.entries.first;
    return '${first.key}: ${first.value.first}';
  }
}

Exception handleFormErrors(Map<String, dynamic> json) {
  if (json['fields'] != null) {
    return FieldsApiException(message: json['message'], fields: json['fields']);
  } else {
    return GeneralApiException(message: json['message']);
  }
}
