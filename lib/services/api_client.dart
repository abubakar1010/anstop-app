import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'locale_service.dart';
import 'session_controller.dart';

class ApiResponse {
  final bool isSuccess;
  final int statusCode;
  final dynamic responseData;
  final String errorMessage;
  final String? errorCode;
  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.responseData,
    String? errorMessage,
    this.errorCode,
  }) : errorMessage = errorMessage ?? AppLocalization.tr.genericErrorMessage;
}

/// All API requests share authentication, one refresh attempt, and stable errors.
class ApiClient {
  ApiClient() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Accept-Language'] = LocaleService.languageCode;
          final token = await SessionController.to.accessToken();
          if (token != null && token.isNotEmpty)
            options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          if (error.response?.statusCode != 401 ||
              request.extra['retried'] == true ||
              request.path.endsWith('/auth/sign-in') ||
              request.path.endsWith('/auth/refresh')) {
            return handler.next(error);
          }
          final current = await SessionController.to.accessToken();
          final token =
              current != null &&
                  request.headers['Authorization'] != 'Bearer $current'
              ? current
              : await SessionController.to.refresh();
          if (token == null) return handler.next(error);
          request.extra['retried'] = true;
          request.headers['Authorization'] = 'Bearer $token';
          if (request.data is FormData)
            request.data = (request.data as FormData).clone();
          try {
            return handler.resolve(await _dio.fetch<dynamic>(request));
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        },
      ),
    );
  }

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 100),
      validateStatus: (status) => status != null && status < 400,
    ),
  );

  Future<ApiResponse> getRequest(
    String url, {
    Map<String, dynamic>? queryParams,
    String? accessToken,
  }) => _request('GET', url, queryParams: queryParams);
  Future<ApiResponse> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? accessToken,
    Map<String, String>? customHeaders,
  }) => _request('POST', url, data: body, headers: customHeaders);
  Future<ApiResponse> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    String? accessToken,
    Map<String, String>? customHeaders,
  }) => _request('PATCH', url, data: body ?? {}, headers: customHeaders);
  Future<ApiResponse> deleteRequest(
    String url, {
    String? accessToken,
    Map<String, String>? customHeaders,
  }) => _request('DELETE', url, headers: customHeaders);

  Future<ApiResponse> patchMultipartRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    String? accessToken,
  }) async => _request('PATCH', url, data: await _form(fields, files));
  Future<ApiResponse> postMultipartRequest(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    String? accessToken,
    Map<String, dynamic>? jsonBody,
  }) async => _request(
    'POST',
    url,
    data: await _form({
      ...?fields,
      if (jsonBody != null) 'body': jsonEncode(jsonBody),
    }, files),
  );

  Future<FormData> _form(
    Map<String, String>? fields,
    Map<String, File>? files,
  ) async {
    final form = FormData();
    fields?.forEach((key, value) => form.fields.add(MapEntry(key, value)));
    if (files != null) {
      for (final entry in files.entries) {
        form.files.add(
          MapEntry(entry.key, await MultipartFile.fromFile(entry.value.path)),
        );
      }
    }
    return form;
  }

  Future<ApiResponse> _request(
    String method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        url,
        data: data,
        queryParameters: queryParams,
        options: Options(method: method, headers: headers),
      );
      return ApiResponse(
        isSuccess: true,
        statusCode: response.statusCode ?? 200,
        responseData: response.data,
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      final code = body is Map ? body['code'] as String? : null;
      SessionController.to.updateFromErrorCode(code);
      return ApiResponse(
        isSuccess: false,
        statusCode: error.response?.statusCode ?? -1,
        responseData: body,
        errorCode: code,
        errorMessage: _messageFor(code),
      );
    } catch (_) {
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: AppLocalization.tr.networkErrorMessage,
      );
    }
  }

  String _messageFor(String? code) {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return AppLocalization.tr.invalidCredentialsMessage;
      case 'UNAUTHENTICATED':
      case 'TOKEN_EXPIRED':
      case 'TOKEN_INVALID':
      case 'REFRESH_TOKEN_INVALID':
        return AppLocalization.tr.sessionExpiredMessage;
      case 'ONBOARDING_REQUIRED':
        return AppLocalization.tr.onboardingRequiredMessage;
      case 'ACCOUNT_PENDING_REVIEW':
        return AppLocalization.tr.accountPendingReviewMessage;
      case 'ACCOUNT_REJECTED':
        return AppLocalization.tr.accountRejectedMessage;
      case 'ACCOUNT_SUSPENDED':
        return AppLocalization.tr.accountSuspendedMessage;
      case 'ACCOUNT_DELETED':
        return AppLocalization.tr.accountDeletedMessage;
      case 'FORBIDDEN':
        return AppLocalization.tr.permissionDeniedMessage;
      case 'RATE_LIMITED':
        return AppLocalization.tr.tooManyRequestsMessage;
      default:
        return AppLocalization.tr.genericErrorMessage;
    }
  }
}
