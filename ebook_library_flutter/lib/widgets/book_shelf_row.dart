// lib/widgets/book_shelf_row.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/ebook.dart';
import '../theme/app_theme.dart';
import '../screens/ebook_detail_screen.dart';

/// A single shelf row displaying up to 4 books on a wooden shelf
class BookShelfRow extends StatelessWidget {
  final List<Ebook>  books;
  final int          startIndex;
  final Future<bool> Function(int id) onBookDeleted;

  const BookShelfRow({
    super.key,
    required this.books,
    required this.startIndex,
    required this.onBookDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Books area
        Container(
          height:  190,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...books.asMap().entries.map(
                (entry) => Expanded(
                  child: _BookSpine(
                    ebook:      entry.value,
                    colorIndex: startIndex + entry.key,
                    onDeleted:  () => onBookDeleted(entry.value.id),
                  ),
                ),
              ),
              // Fill empty slots if < 4 books
              ...List.generate(
                4 - books.length,
                (_) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        ),

        // Wooden shelf plank
        Container(
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end:   Alignment.bottomCenter,
              colors: [
                Color(0xFF9B6B3A),
                AppTheme.shelfWood,
                AppTheme.shelfEdge,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:   Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset:  const Offset(0, 4),
              ),
            ],
          ),
          // Wood grain effect via texture lines
          child: CustomPaint(painter: _WoodGrainPainter()),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Book Spine Widget ─────────────────────────────────────────────────────────

class _BookSpine extends StatefulWidget {
  final Ebook    ebook;
  final int      colorIndex;
  final VoidCallback onDeleted;

  const _BookSpine({
    required this.ebook,
    required this.colorIndex,
    required this.onDeleted,
  });

  @override
  State<_BookSpine> createState() => _BookSpineState();
}

class _BookSpineState extends State<_BookSpine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _liftAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim  = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _liftAnim   = Tween<double>(begin: 0.0, end: -8.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_)  => _controller.forward();
  void _onTapUp(_)    => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.bookColors(widget.colorIndex);
    final ebook  = widget.ebook;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _liftAnim.value),
        child:  Transform.scale(scale: _scaleAnim.value, child: child),
      ),
      child: GestureDetector(
        onTapDown:   _onTapDown,
        onTapUp:     _onTapUp,
        onTapCancel: _onTapCancel,
        onTap:       () => _openDetail(context),
        onLongPress: () => _showContextMenu(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: _buildBookCover(colors, ebook),
        ),
      ),
    );
  }

  Widget _buildBookCover(List<Color> colors, Ebook ebook) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        gradient:     LinearGradient(
          colors: colors,
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:     Colors.black.withOpacity(0.5),
            blurRadius: 6,
            offset:    const Offset(3, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cover image if available
          if (ebook.hasCover)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: CachedNetworkImage(
                imageUrl:   ebook.coverUrl!,
                fit:        BoxFit.cover,
                width:      double.infinity,
                height:     double.infinity,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          // Spine title overlay (always shown, semi-transparent if cover present)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: ebook.hasCover
                    ? LinearGradient(
                        begin:  Alignment.topCenter,
                        end:    Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ebook.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      color:      Colors.white,
                      fontSize:   9,
                      fontWeight: FontWeight.bold,
                      shadows:    [Shadow(color: Colors.black, blurRadius: 3)],
                    ),
                    maxLines:   3,
                    overflow:   TextOverflow.ellipsis,
                  ),
                  if (ebook.author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      ebook.author!,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        color:      Colors.white.withOpacity(0.7),
                        fontSize:   7,
                        shadows:    const [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Format badge
          Positioned(
            top:   6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color:        Colors.black54,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                ebook.formatBadge,
                style: const TextStyle(
                  fontFamily: 'Georgia', color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            EbookDetailScreen(ebook: widget.ebook),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BookContextMenu(
        ebook:     widget.ebook,
        onDeleted: widget.onDeleted,
      ),
    );
  }
}

// ── Book Context Menu ─────────────────────────────────────────────────────────

class _BookContextMenu extends StatelessWidget {
  final Ebook      ebook;
  final VoidCallback onDeleted;

  const _BookContextMenu({required this.ebook, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.onSurface, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text(ebook.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(ebook.authorDisplay, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          _ContextAction(
            icon:  Icons.open_in_new,
            label: 'Open',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EbookDetailScreen(ebook: ebook),
              ));
            },
          ),
          _ContextAction(
            icon:  Icons.delete_outline,
            label: 'Delete',
            color: AppTheme.error,
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDelete(context);
              if (confirmed == true) onDeleted();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surfaceVariant,
      title: const Text('Delete Book', style: TextStyle(fontFamily: 'Georgia', color: AppTheme.onBackground)),
      content: Text(
        'Are you sure you want to delete "${ebook.title}"? This cannot be undone.',
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
}

class _ContextAction extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ContextAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.onBackground,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:  Icon(icon, color: color),
      title:    Text(label, style: TextStyle(fontFamily: 'Georgia', color: color)),
      onTap:    onTap,
    );
  }
}

// ── Wood Grain Painter ────────────────────────────────────────────────────────

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = Colors.black.withOpacity(0.06)
      ..strokeWidth = 0.5
      ..style       = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
