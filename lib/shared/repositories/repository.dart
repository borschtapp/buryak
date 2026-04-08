import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/server_url.dart';
import '../providers/user.dart';

part 'repository.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

/// Determines whether a failed request should be retried.
/// [method] is the HTTP method, [statusCode] is null when no HTTP response was received.
typedef RetryPolicy = bool Function(RequestMethod method, int? statusCode);

bool _defaultRetryPolicy(RequestMethod method, int? statusCode) => method == RequestMethod.get && statusCode == null;

/// Request Query Params
typedef QueryParams = Map<String, dynamic>;

/// Request Body (can be Map or List for batch operations)
typedef RequestBody = dynamic;

/// Response Body
typedef ResponseBody = dynamic;

/// Api Header
typedef ApiHeaderType = Map<String, String>;

// Base class for API repositories. [module] is the fixed base path for the resource.
abstract class Repository {
  final Ref ref;
  final String module;
  final bool isAuth;
  final http.Client? client;
  final String? baseUrlOverride;
  final RetryPolicy? retryPolicy;

  const Repository({
    required this.ref,
    required this.module,
    this.isAuth = true,
    this.client,
    this.baseUrlOverride,
    this.retryPolicy,
  });

  String get effectiveBaseUrl => baseUrlOverride ?? ref.read(serverUrlProvider);

  /// Builds the full URL for the given [path] and optional query params.
  String getUrlString({String path = '', Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('$effectiveBaseUrl$module$path');
    if (queryParams == null || queryParams.isEmpty) return uri.toString();

    final cleanParams = {
      for (final MapEntry(:key, :value) in queryParams.entries)
        if (value != null && value.toString().isNotEmpty && value.toString() != 'null') key: value.toString(),
    };

    if (cleanParams.isEmpty) return uri.toString();

    return uri.replace(queryParameters: cleanParams).toString();
  }

  /// Sends an HTTP request. [method] and [path] are per-call overrides.
  /// Pass [authOverride] to bypass the instance-level [isAuth] for a single call.
  Future<ResponseBody> sendRequest({
    required RequestMethod method,
    String path = '',
    bool? authOverride,
    QueryParams? queryParams,
    RequestBody? body,
    ApiHeaderType? headersCustom,
  }) async {
    final bool effectiveAuth = authOverride ?? isAuth;

    if (effectiveAuth) {
      // Skip async refresh if the token is still valid
      final currentUser = ref.read(authProvider);
      if (currentUser == null || !currentUser.isValidAccessToken()) {
        final success = await ref.read(authProvider.notifier).refreshLogin();
        if (!success && isAuth) {
          await ref.read(authProvider.notifier).logout();
          throw GeneralApiException(message: 'Authentication session expired');
        }
      }
    }

    final String? token = effectiveAuth ? ref.read(authProvider)?.accessToken : null;

    return RequestHandler.call(
      getUrlString(path: path, queryParams: queryParams),
      method,
      authorized: effectiveAuth,
      accessToken: token,
      body: body,
      headersCustom: headersCustom,
      client: client,
      retryPolicy: retryPolicy,
    );
  }

  /// Ensures the [response] is a `Map<String, dynamic>`.
  /// Throws [GeneralApiException] if the response is unexpected.
  Map<String, dynamic> ensureMap(dynamic response) => ensureMapHelper(response);

  /// Ensures the [response] is a `List<dynamic>`.
  /// Throws [GeneralApiException] if the response is not a list.
  List<dynamic> ensureList(dynamic response) {
    if (response is List) return response;
    throw GeneralApiException(message: 'Expected a list but got ${response.runtimeType}');
  }
}

/// Helper function to safely cast a dynamic value to `Map<String, dynamic>`.
Map<String, dynamic> ensureMapHelper(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  throw GeneralApiException(message: 'Expected a Map but got ${value.runtimeType}: $value');
}

enum RequestMethod { get, post, put, delete, patch }

const Duration _kRequestTimeout = Duration(seconds: 30);

extension MethodManager on RequestMethod {
  Future<http.Response> request(Uri url, {Map<String, String>? headers, Object? body, http.Client? client}) async {
    if (client == null) {
      throw ArgumentError('A shared http.Client must be provided via httpClientProvider');
    }

    switch (this) {
      case .get:
        return await client.get(url, headers: headers).timeout(_kRequestTimeout);
      case .post:
        return await client.post(url, headers: headers, body: body).timeout(_kRequestTimeout);
      case .put:
        return await client.put(url, headers: headers, body: body).timeout(_kRequestTimeout);
      case .delete:
        return await client.delete(url, headers: headers, body: body).timeout(_kRequestTimeout);
      case .patch:
        return await client.patch(url, headers: headers, body: body).timeout(_kRequestTimeout);
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
  static Future<ResponseBody> call(
    String urlString,
    RequestMethod method, {
    bool authorized = true,
    String? accessToken,
    RequestBody? body,
    ApiHeaderType? headersCustom,
    http.Client? client,
    RetryPolicy? retryPolicy,
  }) async {
    final shouldRetry = retryPolicy ?? _defaultRetryPolicy;
    Future<ResponseBody> doAttempt() async {
      try {
        final Map<String, String> headers =
            headersCustom ??
            {
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.contentTypeHeader: 'application/json',
              if (authorized && accessToken != null) HttpHeaders.authorizationHeader: 'Bearer $accessToken',
            };

        if (kDebugMode) {
          dev.log('→ ${method.name.toUpperCase()} $urlString${body != null ? '\n  body: ${json.encode(body)}' : ''}', name: 'http');
        }

        final http.Response response = await method.request(
          Uri.parse(urlString),
          headers: headers,
          body: body != null ? json.encode(body) : null,
          client: client,
        );

        if (kDebugMode) {
          dev.log('← ${response.statusCode} $urlString', name: 'http');
        }

        final int statusType = response.statusCode ~/ 100 * 100;
        final responseData = response.bodyBytes.isNotEmpty ? utf8.decode(response.bodyBytes) : null;

        switch (statusType) {
          case 200:
            if (response.statusCode == 204 || responseData == null || responseData.isEmpty) {
              return null;
            }
            try {
              return json.decode(responseData);
            } catch (e) {
              return responseData; // Return as string if not JSON
            }
          case 400:
            if (responseData == null || responseData.isEmpty) {
              throw GeneralApiException(message: 'Request failed with status: ${response.statusCode}');
            }
            try {
              final errorBody = ensureMapHelper(json.decode(responseData));
              throw handleFormErrors(errorBody, statusCode: response.statusCode);
            } catch (e) {
              if (e is GeneralApiException) rethrow;
              throw GeneralApiException(
                message: 'Error ${response.statusCode}: $responseData',
                statusCode: response.statusCode,
              );
            }
          default:
            final message = response.statusCode >= 500
                ? 'Server error: ${response.statusCode}. Please try again later.'
                : 'Request failed with status: ${response.statusCode}';
            throw GeneralApiException(message: message, statusCode: response.statusCode);
        }
      } on GeneralApiException {
        rethrow;
      } catch (e) {
        if (kDebugMode) {
          dev.log('✗ API Error: $e', name: 'http', error: e);
        }
        throw GeneralApiException(message: e.toString(), originalException: e);
      }
    }

    try {
      return await doAttempt();
    } on GeneralApiException catch (e) {
      // Retry once on transient failures according to the retry policy.
      // By default: GET requests with no HTTP response (timeout, socket error).
      if (shouldRetry(method, e.statusCode)) {
        await Future<void>.delayed(const Duration(seconds: 1));
        return await doAttempt();
      }
      rethrow;
    }
  }
}

class GeneralApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalException;

  GeneralApiException({required this.message, this.statusCode, this.originalException});

  bool get isTimeout => originalException is TimeoutException;

  @override
  String toString() {
    return message;
  }
}

class FieldsApiException extends GeneralApiException {
  final Map<String, dynamic> fields;

  FieldsApiException({required super.message, required this.fields, super.statusCode});

  @override
  String toString() {
    var first = fields.entries.first;
    return '${first.key}: ${first.value.first}';
  }
}

Exception handleFormErrors(Map<String, dynamic> json, {int? statusCode}) {
  final message = json['message']?.toString() ?? 'An error occurred';
  if (json['fields'] != null && json['fields'] is Map) {
    return FieldsApiException(
      message: message,
      fields: (json['fields'] as Map).cast<String, dynamic>(),
      statusCode: statusCode,
    );
  } else {
    return GeneralApiException(message: message, statusCode: statusCode);
  }
}
