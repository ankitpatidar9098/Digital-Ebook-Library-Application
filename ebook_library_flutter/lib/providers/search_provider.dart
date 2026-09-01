// lib/providers/search_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ebook.dart';
import '../services/api_service.dart';

class SearchProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Ebook>  _results     = [];
  bool         _isSearching = false;
  String       _query       = '';
  String?      _error;
  String?      _formatFilter;
  String       _sort        = 'recent';
  Timer?       _debounce;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<Ebook> get results     => _results;
  bool        get isSearching => _isSearching;
  String      get query       => _query;
  String?     get error       => _error;
  bool        get hasResults  => _results.isNotEmpty;
  bool        get noResults   => !_isSearching && _query.isNotEmpty && _results.isEmpty;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Debounced search — called on every keystroke
  void onQueryChanged(String query) {
    _query = query;
    _error = null;

    if (query.trim().isEmpty) {
      _results     = [];
      _isSearching = false;
      _debounce?.cancel();
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search());
  }

  void setFormatFilter(String? format) {
    _formatFilter = format;
    if (_query.isNotEmpty) _search();
  }

  void setSort(String sort) {
    _sort = sort;
    if (_query.isNotEmpty) _search();
  }

  void clear() {
    _debounce?.cancel();
    _query       = '';
    _results     = [];
    _isSearching = false;
    _error       = null;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _search() async {
    try {
      _results     = await _api.searchEbooks(_query, sort: _sort, format: _formatFilter);
      _isSearching = false;
      _error       = null;
    } on ApiException catch (e) {
      _isSearching = false;
      _error       = e.toString();
    } catch (e) {
      _isSearching = false;
      _error       = 'Search failed: $e';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
