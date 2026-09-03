// lib/screens/ebook_detail_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/ebook.dart';
import '../providers/ebook_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

class EbookDetailScreen extends StatefulWidget {
  final Ebook ebook;

  const EbookDetailScreen({super.key, required this.ebook});

  @override
  State<EbookDetailScreen> createState() => _EbookDetailScreenState();
}

class _EbookDetailScreenState extends State<EbookDetailScreen> {
  final ApiService _api = ApiService();
  bool   _isDownloading   = false;
  double _downloadProgress = 0.0;
  bool   _isDeleting      = false;

  @override
  Widget build(BuildContext context) {
    final ebook  = widget.ebook;
    final colors = AppTheme.bookColors(ebook.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, ebook, colors),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetadataSection(ebook),
                  const SizedBox(height: 28),
                  _buildActionButtons(context, ebook),
                  const SizedBox(height: 28),
                  if (ebook.description != null && ebook.description!.isNotEmpty) ...[
                    _buildDescription(ebook),
                    const SizedBox(height: 28),
                  ],
                  _buildFileInfo(ebook),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Ebook ebook, List<Color> colors) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned:         true,
      backgroundColor: AppTheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [colors[0].withOpacity(0.8), AppTheme.background],
                ),
              ),
            ),
            // Cover image
            if (ebook.hasCover)
              Center(
                child: Container(
                  width:  150,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: colors[0].withOpacity(0.6), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ebook.fullCoverUrl!,
                      fit:      BoxFit.cover,
                      placeholder: (_, __) => Container(color: colors[0]),
                      errorWidget: (_, __, ___) => _PlaceholderCover(ebook: ebook, colors: colors),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: _PlaceholderCover(ebook: ebook, colors: colors, width: 150, height: 220),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon:    const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: () => _confirmAndDelete(context),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _buildMetadataSection(Ebook ebook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ebook.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.person_outline, size: 14, color: AppTheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ebook.authorDisplay,
                style: const TextStyle(
                  fontFamily: 'Georgia', color: AppTheme.primary, fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InfoChip(label: ebook.formatBadge),
            const SizedBox(width: 8),
            _InfoChip(label: ebook.fileSizeHuman),
            const SizedBox(width: 8),
            _InfoChip(label: ebook.formattedDate),
            if (ebook.hasBeenRead) ...[
              const SizedBox(width: 8),
              _InfoChip(label: 'Page ${ebook.readPosition}', color: AppTheme.secondary),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Ebook ebook) {
    return Column(
      children: [
        // Read button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openReader(context, ebook),
            icon:  const Icon(Icons.menu_book, size: 18),
            label: Text(ebook.hasBeenRead ? 'Continue Reading' : 'Read Now'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Download button
        if (_isDownloading)
          Column(
            children: [
              LinearProgressIndicator(
                value:     _downloadProgress,
                color:     AppTheme.primary,
                backgroundColor: AppTheme.surfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 12),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _downloadBook(context, ebook),
              icon:      const Icon(Icons.download_outlined, size: 18, color: AppTheme.secondary),
              label:     const Text('Download',
                  style: TextStyle(fontFamily: 'Georgia', color: AppTheme.secondary)),
              style: OutlinedButton.styleFrom(
                padding:     const EdgeInsets.symmetric(vertical: 14),
                side:        const BorderSide(color: AppTheme.secondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(Ebook ebook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ebook.description!,
          style: const TextStyle(
            fontFamily: 'Georgia', fontSize: 14, color: AppTheme.onSurface, height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo(Ebook ebook) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'File Information',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onBackground),
          ),
          const SizedBox(height: 12),
          _FileInfoRow(label: 'Filename',    value: ebook.filename ?? '-'),
          _FileInfoRow(label: 'Format',      value: ebook.fileFormat.toUpperCase()),
          _FileInfoRow(label: 'File size',   value: ebook.fileSizeHuman),
          _FileInfoRow(label: 'Uploaded',    value: ebook.formattedDate),
          if (ebook.lastReadAt != null)
            _FileInfoRow(label: 'Last read', value: _formatDateTime(ebook.lastReadAt!)),
        ],
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _openReader(BuildContext context, Ebook ebook) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReaderScreen(ebook: ebook)),
    );
  }

  Future<void> _downloadBook(BuildContext context, Ebook ebook) async {
    if (ebook.fullFileUrl == null) {
      _showSnack(context, 'No file available to download', isError: true);
      return;
    }

    setState(() { _isDownloading = true; _downloadProgress = 0.0; });

    try {
      final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final savedPath = await _api.downloadEbook(
        ebook,
        savePath: dir.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (mounted) {
        setState(() => _isDownloading = false);
        _showSnack(context, 'Downloaded to ${savedPath.split('/').last}');
        // Open file
        await OpenFilex.open(savedPath);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        _showSnack(context, e.toString(), isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        _showSnack(context, 'Download failed: $e', isError: true);
      }
    }
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text('Delete Book', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground)),
        content: Text(
          'Are you sure you want to delete "${widget.ebook.title}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final success = await context.read<EbookProvider>().deleteEbook(widget.ebook.id);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        _showSnack(context, '${widget.ebook.title} deleted');
      } else {
        setState(() => _isDeleting = false);
        _showSnack(context, 'Failed to delete book', isError: true);
      }
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(message, style: const TextStyle(fontFamily: 'Georgia')),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

// ── Sub Widgets ───────────────────────────────────────────────────────────────

class _PlaceholderCover extends StatelessWidget {
  final Ebook       ebook;
  final List<Color> colors;
  final double?     width;
  final double?     height;

  const _PlaceholderCover({
    required this.ebook,
    required this.colors,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        gradient:     LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, color: Colors.white70, size: 40),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              ebook.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Georgia', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color  color;

  const _InfoChip({required this.label, this.color = AppTheme.surfaceVariant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground, fontSize: 11),
      ),
    );
  }
}

class _FileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _FileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onSurface, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
