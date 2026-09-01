// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ebook.dart';
import '../providers/search_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import 'ebook_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode        = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor:    AppTheme.surface,
        automaticallyImplyLeading: false,
        title: TextField(
          controller:  _searchController,
          focusNode:   _focusNode,
          onChanged:   (v) => context.read<SearchProvider>().onQueryChanged(v),
          style:       const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground),
          cursorColor: AppTheme.primary,
          decoration: InputDecoration(
            hintText:  'Search by title, author, or filename...',
            hintStyle: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 14),
            filled:    false,
            border:    InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: AppTheme.onSurface),
            suffixIcon: Consumer<SearchProvider>(
              builder: (_, provider, __) =>
                  provider.query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.onSurface),
                          onPressed: () {
                            _searchController.clear();
                            provider.clear();
                          },
                        )
                      : const SizedBox.shrink(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Georgia', color: AppTheme.primary),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterBar(),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (_, provider, __) {
          // Initial / empty query state
          if (provider.query.isEmpty) {
            return _buildInitialState();
          }

          // Searching spinner
          if (provider.isSearching) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          // Error
          if (provider.error != null) {
            return ErrorView(message: provider.error!, onRetry: null);
          }

          // No results
          if (provider.noResults) {
            return _buildNoResults(provider.query);
          }

          // Results
          return _buildResults(provider.results, provider.query);
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Consumer<SearchProvider>(
      builder: (_, provider, __) {
        return Container(
          color:   AppTheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Text('Format: ', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 11)),
              _FilterChip(
                label:    'All',
                selected: provider.query.isEmpty || true, // simplified
                onTap:    () => provider.setFormatFilter(null),
              ),
              const SizedBox(width: 6),
              _FilterChip(label: 'PDF',  selected: false, onTap: () => provider.setFormatFilter('pdf')),
              const SizedBox(width: 6),
              _FilterChip(label: 'EPUB', selected: false, onTap: () => provider.setFormatFilter('epub')),
              const Spacer(),
              const Text('Sort: ', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 11)),
              _FilterChip(label: 'Recent', selected: true,  onTap: () => provider.setSort('recent')),
              const SizedBox(width: 6),
              _FilterChip(label: 'A–Z',   selected: false, onTap: () => provider.setSort('title')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search, size: 64, color: AppTheme.surfaceVariant),
          SizedBox(height: 16),
          Text(
            'Search your library',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: AppTheme.onSurface),
          ),
          SizedBox(height: 8),
          Text(
            'Find books by title, author, or filename',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 13, color: AppTheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppTheme.surfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: const TextStyle(fontFamily: 'Georgia', fontSize: 18, color: AppTheme.onBackground),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or check the spelling',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 13, color: AppTheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<Ebook> results, String query) {
    return ListView.builder(
      padding:     const EdgeInsets.symmetric(vertical: 8),
      itemCount:   results.length,
      itemBuilder: (context, index) {
        return _SearchResultCard(ebook: results[index], query: query);
      },
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color:        selected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: selected ? AppTheme.primary : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize:   10,
            color:      selected ? AppTheme.primary : AppTheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Search Result Card ────────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final Ebook  ebook;
  final String query;

  const _SearchResultCard({required this.ebook, required this.query});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.bookColors(ebook.id);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EbookDetailScreen(ebook: ebook)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Mini book cover
            Container(
              width:  50,
              height: 70,
              decoration: BoxDecoration(
                gradient:     LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(4),
                boxShadow:    [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 6)],
              ),
              child: Center(
                child: Text(
                  ebook.formatBadge,
                  style: const TextStyle(fontFamily: 'Georgia', color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(text: ebook.title, query: query,
                      style: const TextStyle(fontFamily: 'Georgia', fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.onBackground)),
                  const SizedBox(height: 2),
                  _HighlightedText(
                    text:  ebook.authorDisplay,
                    query: query,
                    style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(ebook.formatBadge, style: const TextStyle(fontFamily: 'Georgia', fontSize: 10, color: AppTheme.onSurface)),
                      const Text(' · ', style: TextStyle(color: AppTheme.onSurface)),
                      Text(ebook.fileSizeHuman, style: const TextStyle(fontFamily: 'Georgia', fontSize: 10, color: AppTheme.onSurface)),
                      const Text(' · ', style: TextStyle(color: AppTheme.onSurface)),
                      Text(ebook.formattedDate, style: const TextStyle(fontFamily: 'Georgia', fontSize: 10, color: AppTheme.onSurface)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.onSurface, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Highlighted Text (search term highlight) ──────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String    text;
  final String    query;
  final TextStyle style;

  const _HighlightedText({required this.text, required this.query, required this.style});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);

    final lowerText  = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index      = lowerText.indexOf(lowerQuery);

    if (index == -1) return Text(text, style: style);

    return RichText(
      text: TextSpan(
        style:    style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text:  text.substring(index, index + query.length),
            style: style.copyWith(
              backgroundColor: AppTheme.primary.withOpacity(0.3),
              color:           AppTheme.primary,
              fontWeight:      FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
