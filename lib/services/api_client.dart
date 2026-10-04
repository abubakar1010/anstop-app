
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
class ApiResponse {
  final bool isSuccess;
  final int statusCode;
  final dynamic responseData;
  final String errorMessage;

  ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.responseData,
    this.errorMessage = 'Something went wrong',
  });
}

class ApiClient {
  // using the logger package
  final Logger _logger = Logger();

  // Timeout duration (30 seconds)
  static const Duration _requestTimeout = Duration(seconds: 100);

  // Show timeout dialog
  void _showTimeoutDialog() {
    // Close any existing loading dialogs first
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      AlertDialog(
        title: Text(AppLocalization.tr.serverErrorTitle),
        content: Text(AppLocalization.tr.serverUnavailableMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalization.tr.okButton),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Get Request
  Future<ApiResponse> getRequest(String url,  {Map<String, dynamic>? queryParams, String? accessToken}) async {
    try {

      // Map<String, String> headers = {
      //   'content-type' : 'application/json'
      // };
      // if (accessToken != null) {
      //   headers['token'] = accessToken;
      // }

      final headers = <String, String>{
        'Authorization': accessToken != null ? 'Bearer $accessToken' : '',
        //'Authorization': token ?? '',
        // 'Content-Type': files != null ? 'multipart/form-data' : 'application/json',
      };

      if (queryParams != null) {
        url += '?';
        for (String param in queryParams.keys) {
          url += '$param=${queryParams[param]}&';
        }
      }

      Uri uri = Uri.parse(url);
      //_logger.i('URL => $url');
      _logRequest(url);
      Response response = await get(uri, headers: headers).timeout(
        _requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out after ${_requestTimeout.inSeconds} seconds');
        },
      );

      // Log status code immediately
      _logger.i('📊 STATUS CODE => ${response.statusCode}');

      _logResponse(url, response.statusCode, response.headers, response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: 'Empty response body',
          );
        }
        final decodedMessage = jsonDecode(response.body);
        return ApiResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedMessage,
        );
      } else {
        if (response.body.isEmpty) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: '',
          );
        }
        try {
          final decodedMessage = jsonDecode(response.body);
          // Try to extract errorMessage field first (backend format), fallback to msg, then message
          String errorMsg = decodedMessage['errorMessage'] ??
              decodedMessage['msg'] ??
              decodedMessage['message'] ??
              'Something went wrong';
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: errorMsg,
          );
        } catch (e) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      _logger.e('Timeout: ${e.message}');
      _showTimeoutDialog();
      return ApiResponse(
        isSuccess: false,
        statusCode: 408, // Request Timeout
        errorMessage: 'The server is not working. Please try again later.',
      );
    } catch (e) {
      _logResponse(url, -1, null, '');
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }


  /// Post Request
  /// POST JSON Request — ✅ Now supports headers
  Future<ApiResponse> postRequest(
      String url, {
        Map<String, dynamic>? body,
        String? accessToken,
        Map<String, String>? customHeaders,
      }) async {
    try {
      // Start with default JSON header
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add Authorization if token provided
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // Merge custom headers (if any)
      if (customHeaders != null) {
        headers.addAll(customHeaders);
      }

      _logRequest(url, headers, body);

      _logger.i('🚀 Sending POST request... (timeout: ${_requestTimeout.inSeconds}s)');
      final startTime = DateTime.now();

      final response = await post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          final elapsed = DateTime.now().difference(startTime);
          _logger.e('⏱️ Request timeout triggered after ${elapsed.inSeconds}s');
          throw TimeoutException('Request timed out after ${_requestTimeout.inSeconds} seconds');
        },
      );

      final elapsed = DateTime.now().difference(startTime);
      _logger.i('✅ Response received in ${elapsed.inMilliseconds}ms');

      // Log status code immediately
      _logger.i('📊 STATUS CODE => ${response.statusCode}');

      _logResponse(url, response.statusCode, response.headers, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return ApiResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decoded,
        );
      } else {
        try {
          final decoded = jsonDecode(response.body);
          // Try to extract error message from multiple possible fields
          String errorMsg = decoded is Map
              ? (decoded['errorMessage'] ??
              decoded['msg'] ??
              decoded['message'] ??
              '').toString()
              : '';
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: errorMsg,
          );
        } catch (_) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: 'Something went wrong. Please try again.',
          );
        }
      }
    } on TimeoutException catch (e) {
      _logger.e('⏱️ TimeoutException caught: ${e.message}');
      _showTimeoutDialog();
      return ApiResponse(
        isSuccess: false,
        statusCode: 408, // Request Timeout
        errorMessage: 'The server is not working. Please try again later.',
      );
    } on SocketException catch (e) {
      _logger.e('🔌 SocketException: ${e.message}');
      _logger.e('   Address: ${e.address}');
      _logger.e('   Port: ${e.port}');
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'Network error: ${e.message}',
      );
    } on FormatException catch (e) {
      _logger.e('📝 FormatException: ${e.message}');
      _logger.e('   Source: ${e.source}');
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'Format error: ${e.message}',
      );
    } catch (e, stackTrace) {
      _logger.e('❌ Unexpected exception type: ${e.runtimeType}');
      _logger.e('   Exception: $e');
      _logger.e('   StackTrace: $stackTrace');
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  /// DELETE Request
  Future<ApiResponse> deleteRequest(
      String url, {
        String? accessToken,
        Map<String, String>? customHeaders,
      }) async {
    try {
      final headers = <String, String>{};

      if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';
      if (customHeaders != null) headers.addAll(customHeaders);

      _logRequest(url, headers, null);

      final response = await delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out after ${_requestTimeout.inSeconds} seconds');
        },
      );

      // Log status code immediately
      _logger.i('📊 STATUS CODE => ${response.statusCode}');

      _logResponse(url, response.statusCode, response.headers, response.body);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        // 204 = No Content (common for successful DELETE)
        if (response.body.isEmpty) {
          return ApiResponse(
            isSuccess: true,
            statusCode: response.statusCode,
            responseData: {'message': 'Deleted successfully'},
          );
        }
        return ApiResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: jsonDecode(response.body),
        );
      } else {
        try {
          final decoded = jsonDecode(response.body);
          // Try to extract errorMessage field first, fallback to msg, then message
          String errorMsg = decoded['errorMessage'] ??
              decoded['msg'] ??
              decoded['message'] ??
              '';
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: errorMsg,
          );
        } catch (_) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      _logger.e('Timeout: ${e.message}');
      _showTimeoutDialog();
      return ApiResponse(
        isSuccess: false,
        statusCode: 408, // Request Timeout
        errorMessage: 'The server is not working. Please try again later.',
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  /// PATCH JSON Request
  Future<ApiResponse> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        String? accessToken,
        Map<String, String>? customHeaders,
      }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (accessToken != null) headers['Authorization'] = 'Bearer $accessToken';
      if (customHeaders != null) headers.addAll(customHeaders);

      // 🛑 Prevent sending `"null"`
      final encodedBody = body == null ? '{}' : jsonEncode(body);

      _logRequest(url, headers, body);

      final response = await patch(
        Uri.parse(url),
        headers: headers,
        body: encodedBody,   // ✔ Always valid JSON
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out after ${_requestTimeout.inSeconds} seconds');
        },
      );

      _logResponse(url, response.statusCode, response.headers, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: jsonDecode(response.body),
        );
      } else {
        try {
          final decoded = json.decode(response.body);
          // Try to extract error message from multiple possible fields
          String errorMsg = decoded is Map
              ? (decoded['errorMessage'] ??
              decoded['msg'] ??
              decoded['message'] ??
              '').toString()
              : '';

          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: errorMsg,
          );
        } catch (_) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      _logger.e('Timeout: ${e.message}');
      _showTimeoutDialog();
      return ApiResponse(
        isSuccess: false,
        statusCode: 408, // Request Timeout
        errorMessage: 'The server is not working. Please try again later.',
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }



  void _logRequest(String url,
      [Map<String, dynamic>? headers, Map<String, dynamic>? body]) {
    // the params in [] means these are optional params
    _logger.i('URL => $url\nHEADERS => $headers\nBODY => $body');
  }

  void _logResponse(String url, int statusCode, Map<String, String>? headers,
      String body, [String? errorMessage]) {
    if (errorMessage != null) {
      _logger.e(
          'URL => $url\nERROR MESSAGE => $errorMessage');
    } else {
      _logger.i(
          'URL => $url\nHEADERS => $headers\nSTATUS CODE => $statusCode\nBODY => $body');
    }
  }



  /// PATCH Multipart Request (for file uploads + form fields with PATCH method)
  Future<ApiResponse> patchMultipartRequest(
      String url, {
        Map<String, String>? fields,
        Map<String, File>? files,
        String? accessToken,
      }) async {
    try {
      final request = http.MultipartRequest('PATCH', Uri.parse(url));

      // Add headers
      request.headers['Authorization'] = accessToken != null ? 'Bearer $accessToken' : '';

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final String fieldName = entry.key;
          final File file = entry.value;

          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          final filename = p.basename(file.path);

          final fileStream = http.ByteStream(file.openRead());
          final length = await file.length();

          final multipartFile = http.MultipartFile(fieldName, fileStream, length,
              filename: filename, contentType: MediaType.parse(mimeType));

          request.files.add(multipartFile);
        }
      }

      _logRequest(url, request.headers, {'fields': fields?.keys, 'files': files?.keys});

      final streamedResponse = await request.send().timeout(
        _requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out after ${_requestTimeout.inSeconds} seconds');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(url, response.statusCode, response.headers, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        return ApiResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedData,
        );
      } else {
        try {
          final decoded = jsonDecode(response.body);
          // Try to extract error message from multiple possible fields
          String errorMsg = decoded is Map
              ? (decoded['errorMessage'] ??
              decoded['msg'] ??
              decoded['message'] ??
              '').toString()
              : '';
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: errorMsg,
          );
        } catch (_) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      _logger.e('Timeout: ${e.message}');
      _showTimeoutDialog();
      return ApiResponse(
        isSuccess: false,
        statusCode: 408, // Request Timeout
        errorMessage: 'The server is not working. Please try again later.',
      );
    } catch (e, stackTrace) {
      _logger.e(stackTrace);
      _logResponse(url, -1, null, '', e.toString());
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  /// Post Multipart Request (for file uploads + form fields)
  Future<ApiResponse> postMultipartRequest(
      String url, {
        Map<String, String>? fields,
        Map<String, File>? files,
        String? accessToken,
        Map<String, dynamic>? jsonBody,
      }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['Authorization'] = accessToken != null ? 'Bearer $accessToken' : '';

      // If jsonBody is provided, add it as a JSON string in the body field
      if (jsonBody != null) {
        request.fields['body'] = jsonEncode(jsonBody);
      }

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        _logger.i('🔸 NetworkCaller.postMultipartRequest - Processing ${files.length} files');
        for (final entry in files.entries) {
          final String fieldName = entry.key;
          final File file = entry.value;

          _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _logger.i('📎 File Field: $fieldName');
          _logger.i('   Path: ${file.path}');
          _logger.i('   Exists: ${file.existsSync()}');

          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          final filename = p.basename(file.path);

          _logger.i('   Filename: $filename');
          _logger.i('   MIME Type: $mimeType');

          final fileStream = http.ByteStream(file.openRead());
          final length = await file.length();

          _logger.i('   File Size: $length bytes');
          _logger.i('   MediaType object: ${MediaType.parse(mimeType)}');

          final multipartFile = http.MultipartFile(fieldName, fileStream, length,
              filename: filename, contentType: MediaType.parse(mimeType));

          request.files.add(multipartFile);
          _logger.i('✅ File added to multipart request');
          _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        }
      }

      _logRequest(url, request.headers, {'fields': fields?.keys, 'files': files?.keys});

      _logger.i('🚀 Sending multipart POST request to: $url');
      _logger.i('   Total files: ${request.files.length}');
      _logger.i('   Total fields: ${request.fields.length}');

      final streamedResponse = await request.send().timeout(
        _requestTimeout,
        onTimeout: () {
          throw TimeoutException('Request timed out after ${_requestTimeout.inSeconds} seconds');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      _logger.i('📥 Response received:');
      _logger.i('   Status Code: ${response.statusCode}');
      _logger.i('   Body length: ${response.body.length} chars');

      _logResponse(url, response.statusCode, response.headers, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        _logger.i('✅ POST Multipart Request SUCCESS');
        return ApiResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedData,
        );
      } else {
        _logger.e('❌ POST Multipart Request FAILED - Status ${response.statusCode}');
        try {
          final decoded = jsonDecode(response.body);
          // Try to extract error message from multiple possible fields
          String errorMsg = decoded is Map
              ? (decoded['errorMessage'] ??
              decoded['msg'] ??
              decoded['message'] ??
              '').toString()
              : '';
          _logger.e('   Error message: $errorMsg');
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: errorMsg,
          );
        } catch (_) {
          return ApiResponse(
            isSuccess: false,
            statusCode: response.statusCode,
            errorMessage: '',
          );
        }
      }
    } on TimeoutException catch (e) {
      _logger.e('Timeout: ${e.message}');
      _showTimeoutDialog();
      return ApiResponse(
        isSuccess: false,
        statusCode: 408, // Request Timeout
        errorMessage: 'The server is not working. Please try again later.',
      );
    } catch (e, stackTrace) {
      _logger.e('❌ Exception in postMultipartRequest:');
      _logger.e(e.toString());
      _logger.e(stackTrace);
      _logResponse(url, -1, null, '', e.toString());
      return ApiResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }
}
