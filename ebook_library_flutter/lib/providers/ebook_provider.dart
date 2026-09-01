// lib/providers/ebook_provider.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/ebook.dart';
import '../services/api_service.dart';

enum LoadState { idle, loading, loaded, error }

enum SortOption { recent, title, author }

class EbookProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ── State ──────────────────────────────────────────────────────────────────
  List<Ebook>  _ebooks      = [];
  LoadState    _state       = LoadState.idle;
  String?      _errorMessage;
  SortOption   _sortOption  = SortOption.recent;
  String?      _formatFilter;

  // Upload state
  bool   _isUploading   = false;
  double _uploadProgress = 0.0;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Ebook> get ebooks      => _ebooks;
  LoadState   get state       => _state;
  String?     get errorMessage => _errorMessage;
  SortOption  get sortOption  => _sortOption;
  String?     get formatFilter => _formatFilter;
  bool        get isUploading  => _isUploading;
  double      get uploadProgress => _uploadProgress;
  bool        get isLoading   => _state == LoadState.loading;
  bool        get hasError    => _state == LoadState.error;
  bool        get isEmpty     => _state == LoadState.loaded && _ebooks.isEmpty;

  List<Ebook> get recentlyRead =>
      _ebooks.where((e) => e.hasBeenRead).toList()
        ..sort((a, b) => (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)));

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> loadEbooks() async {
    _state        = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _ebooks = await _api.getEbooks(
        sort:   _sortOptionString,
        format: _formatFilter,
      );
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _state        = LoadState.error;
      _errorMessage = e.toString();
    } catch (e) {
      _state        = LoadState.error;
      _errorMessage = 'Unexpected error: $e';
    }

    notifyListeners();
  }

  Future<void> refresh() => loadEbooks();

  Future<Ebook?> uploadEbook({
    required PlatformFile file,
    required String title,
    String?         author,
    String?         description,
    PlatformFile?   coverImage,
  }) async {
    _isUploading   = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final newEbook = await _api.uploadEbook(
        file:        file,
        title:       title,
        author:      author,
        description: description,
        coverImage:  coverImage,
        onSendProgress: (sent, total) {
          if (total > 0) {
            _uploadProgress = sent / total;
            notifyListeners();
          }
        },
      );
      _ebooks.insert(0, newEbook);
      _isUploading = false;
      notifyListeners();
      return newEbook;
    } on ApiException catch (e) {
      _isUploading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteEbook(int id) async {
    try {
      await _api.deleteEbook(id);
      _ebooks.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateReadPosition(int ebookId, int page) async {
    try {
      await _api.updateReadPosition(ebookId, page);
      final index = _ebooks.indexWhere((e) => e.id == ebookId);
      if (index != -1) {
        _ebooks[index] = _ebooks[index].copyWith(
          readPosition: page,
          lastReadAt:   DateTime.now(),
        );
        notifyListeners();
      }
    } catch (_) {
      // Non-fatal — position save is best-effort
    }
  }

  void setSortOption(SortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    loadEbooks();
  }

  void setFormatFilter(String? format) {
    if (_formatFilter == format) return;
    _formatFilter = format;
    loadEbooks();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  String get _sortOptionString {
    switch (_sortOption) {
      case SortOption.title:   return 'title';
      case SortOption.author:  return 'author';
      case SortOption.recent:  return 'recent';
    }
  }
}
