// lib/services/api_service.dart
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/ebook.dart';

/// Exception thrown when API calls fail
class ApiException implements Exception {
  final String message;
  final int?   statusCode;
  final List<String> details;

  const ApiException(this.message, {this.statusCode, this.details = const []});

  @override
  String toString() =>
      details.isNotEmpty ? '$message: ${details.join(', ')}' : message;
}

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:3000/api';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers:        {'Accept': 'application/json'},
      ),
    );

    // Logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody:  true,
          responseBody: true,
          error:        true,
        ),
      );
    }

    // Error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('[ApiService] Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // ── Ebooks ──────────────────────────────────────────────────────────────────

  /// Fetch list of ebooks with optional sort and format filter
  Future<List<Ebook>> getEbooks({
    String sort   = 'recent',
    String? format,
    int    page   = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'sort': sort, 'page': page};
      if (format != null) queryParams['format'] = format;

      final response = await _dio.get('/ebooks', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      final list = data['ebooks'] as List<dynamic>;
      return list.map((e) => Ebook.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Search ebooks by keyword
  Future<List<Ebook>> searchEbooks(String query, {String sort = 'recent', String? format}) async {
    try {
      final params = <String, dynamic>{'q': query, 'sort': sort};
      if (format != null) params['format'] = format;

      final response = await _dio.get('/ebooks/search', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final list = data['ebooks'] as List<dynamic>;
      return list.map((e) => Ebook.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get a single ebook by ID
  Future<Ebook> getEbook(int id) async {
    try {
      final response = await _dio.get('/ebooks/$id');
      final data = response.data as Map<String, dynamic>;
      return Ebook.fromJson((data['ebook'] ?? data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload a new ebook file with metadata
  Future<Ebook> uploadEbook({
    required PlatformFile file,
    required String title,
    String?         author,
    String?         description,
    PlatformFile?   coverImage,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'ebook[title]':  title,
        if (author?.isNotEmpty == true) 'ebook[author]': author,
        if (description?.isNotEmpty == true) 'ebook[description]': description,
        'ebook[file]': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
        if (coverImage != null)
          'ebook[cover_image]': MultipartFile.fromBytes(
            coverImage.bytes!,
            filename: coverImage.name,
          ),
      });

      final response = await _dio.post(
        '/ebooks',
        data:            formData,
        onSendProgress:  onSendProgress,
      );
      final data = response.data as Map<String, dynamic>;
      return Ebook.fromJson((data['ebook'] ?? data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Download an ebook to local storage
  Future<String> downloadEbook(
    Ebook ebook, {
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final url = '$_baseUrl/ebooks/${ebook.id}/download';
      final filename = ebook.filename ?? '${ebook.title}.${ebook.fileFormat}';
      final fullPath = p.join(savePath, filename);

      await _dio.download(
        url,
        fullPath,
        onReceiveProgress: onReceiveProgress,
        options: Options(followRedirects: true, receiveTimeout: const Duration(minutes: 2)),
      );
      return fullPath;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update read position for an ebook
  Future<void> updateReadPosition(int ebookId, int page) async {
    try {
      await _dio.patch(
        '/ebooks/$ebookId/read_position',
        data: {'page': page},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete an ebook
  Future<void> deleteEbook(int id) async {
    try {
      await _dio.delete('/ebooks/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Error Handling ──────────────────────────────────────────────────────────

  ApiException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String message;
    List<String> details = [];

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Request timed out. Please check your connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Cannot connect to server. Make sure the backend is running.';
    } else if (responseData is Map<String, dynamic>) {
      message = responseData['error'] as String? ?? 'An error occurred';
      final rawDetails = responseData['details'];
      if (rawDetails is List) {
        details = rawDetails.cast<String>();
      }
    } else {
      message = e.message ?? 'An unexpected error occurred';
    }

    return ApiException(message, statusCode: statusCode, details: details);
  }
}
