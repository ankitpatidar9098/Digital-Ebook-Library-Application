// lib/screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ebook.dart';
import '../providers/ebook_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/book_shelf_row.dart';
import '../widgets/empty_shelf.dart';
import '../widgets/error_view.dart';
import '../widgets/shelf_shimmer.dart';
import 'search_screen.dart';
import 'upload_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimController;
  late Animation<double>   _fabScale;

  static const int _booksPerShelf = 4;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOutBack),
    );
    _fabAnimController.forward();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          _buildSortFilterBar(context),
          _buildRecentlyReadSection(context),
          _buildShelfContent(context),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToUpload(context),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.black87,
          elevation:       8,
          icon:            const Icon(Icons.add),
          label:           const Text('Add Book',
              style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned:         true,
      stretch:        true,
      backgroundColor: AppTheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [Color(0xFF1A2540), Color(0xFF0D0F14)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'My Library',
                        style: TextStyle(
                          fontFamily:  'Georgia',
                          fontSize:    26,
                          fontWeight:  FontWeight.bold,
                          color:       AppTheme.onBackground,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppTheme.onBackground),
                        onPressed: () => _navigateToSearch(context),
                        tooltip: 'Search books',
                      ),
                    ],
                  ),
                  Consumer<EbookProvider>(
                    builder: (_, provider, __) {
                      if (provider.state == LoadState.loaded) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${provider.ebooks.length} book${provider.ebooks.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              color:      AppTheme.onSurface,
                              fontSize:   13,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text(
          'My Library',
          style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 12),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _navigateToSearch(context),
          tooltip: 'Search',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Sort / Filter bar ─────────────────────────────────────────────────────

  Widget _buildSortFilterBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<EbookProvider>(
        builder: (_, provider, __) {
          return Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                const Text('Sort:',
                    style: TextStyle(color: AppTheme.onSurface, fontSize: 12, fontFamily: 'Georgia')),
                const SizedBox(width: 8),
                _SortChip(
                  label:    'Recent',
                  selected: provider.sortOption == SortOption.recent,
                  onTap:    () => provider.setSortOption(SortOption.recent),
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label:    'Title',
                  selected: provider.sortOption == SortOption.title,
                  onTap:    () => provider.setSortOption(SortOption.title),
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label:    'Author',
                  selected: provider.sortOption == SortOption.author,
                  onTap:    () => provider.setSortOption(SortOption.author),
                ),
                const Spacer(),
                // Format filter
                PopupMenuButton<String?>(
                  onSelected: provider.setFormatFilter,
                  color:      AppTheme.surfaceVariant,
                  child:      Row(
                    children: [
                      Text(
                        provider.formatFilter?.toUpperCase() ?? 'All',
                        style: const TextStyle(
                          color: AppTheme.primary, fontSize: 12, fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.primary, size: 18),
                    ],
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: null,   child: Text('All Formats',  style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground))),
                    const PopupMenuItem(value: 'pdf',  child: Text('PDF only',     style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground))),
                    const PopupMenuItem(value: 'epub', child: Text('EPUB only',    style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Recently Read ─────────────────────────────────────────────────────────

  Widget _buildRecentlyReadSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<EbookProvider>(
        builder: (_, provider, __) {
          final recent = provider.recentlyRead.take(5).toList();
          if (recent.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Continue Reading',
                  style: TextStyle(
                    fontFamily:  'Georgia',
                    fontSize:    16,
                    fontWeight:  FontWeight.bold,
                    color:       AppTheme.onBackground,
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:         const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:       recent.length,
                  itemBuilder: (context, i) => _RecentReadCard(ebook: recent[i]),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppTheme.surfaceVariant, height: 1),
            ],
          );
        },
      ),
    );
  }

  // ── Shelf Content ─────────────────────────────────────────────────────────

  Widget _buildShelfContent(BuildContext context) {
    return Consumer<EbookProvider>(
      builder: (_, provider, __) {
        switch (provider.state) {
          case LoadState.loading:
            return const SliverToBoxAdapter(child: ShelfShimmer());

          case LoadState.error:
            return SliverToBoxAdapter(
              child: ErrorView(
                message:   provider.errorMessage ?? 'Failed to load library',
                onRetry:   provider.loadEbooks,
              ),
            );

          case LoadState.loaded:
            if (provider.isEmpty) {
              return const SliverToBoxAdapter(child: EmptyShelf());
            }
            return _buildShelves(provider.ebooks);

          case LoadState.idle:
            return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }

  Widget _buildShelves(List<Ebook> ebooks) {
    final rows = <List<Ebook>>[];
    for (var i = 0; i < ebooks.length; i += _booksPerShelf) {
      rows.add(ebooks.sublist(i,
          i + _booksPerShelf > ebooks.length ? ebooks.length : i + _booksPerShelf));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final rowStartIndex = index * _booksPerShelf;
          return BookShelfRow(
            books:          rows[index],
            startIndex:     rowStartIndex,
            onBookDeleted:  (id) => context.read<EbookProvider>().deleteEbook(id),
          );
        },
        childCount: rows.length,
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _navigateToUpload(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const UploadScreen()),
    );
    if (result == true && context.mounted) {
      context.read<EbookProvider>().refresh();
    }
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }
}

// ── Sort Chip Widget ──────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        selected ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(
            color: selected ? AppTheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily:  'Georgia',
            fontSize:    11,
            color:       selected ? Colors.black87 : AppTheme.onSurface,
            fontWeight:  selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Recent Read Card ──────────────────────────────────────────────────────────

class _RecentReadCard extends StatelessWidget {
  final Ebook ebook;

  const _RecentReadCard({required this.ebook});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.bookColors(ebook.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/reader', arguments: ebook);
      },
      child: Container(
        width:   80,
        margin:  const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                gradient:     LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: Center(
                child: Text(
                  ebook.title.substring(0, ebook.title.length > 10 ? 10 : ebook.title.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Georgia', color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Page ${ebook.readPosition}',
              style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.primary, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
