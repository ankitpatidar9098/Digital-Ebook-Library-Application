// lib/widgets/empty_shelf.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Beautiful empty state shown when the library has no books
class EmptyShelf extends StatefulWidget {
  const EmptyShelf({super.key});

  @override
  State<EmptyShelf> createState() => _EmptyShelfState();
}

class _EmptyShelfState extends State<EmptyShelf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty shelf illustration
          _EmptyShelfIllustration(),

          const SizedBox(height: 32),

          const Text(
            'Your shelf is empty',
            style: TextStyle(
              fontFamily:  'Georgia',
              fontSize:    22,
              fontWeight:  FontWeight.bold,
              color:       AppTheme.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add your first ebook to start\nbuilding your digital library',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize:   14,
              color:      AppTheme.onSurface,
              height:     1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/upload'),
            icon:  const Icon(Icons.add, size: 18),
            label: const Text('Add Your First Book'),
          ),
        ],
      ),
    );
  }
}

class _EmptyShelfIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  280,
      height: 180,
      child: CustomPaint(painter: _EmptyShelfPainter()),
    );
  }
}

class _EmptyShelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shelfPaint = Paint()
      ..shader = const LinearGradient(
        begin:  Alignment.topCenter,
        end:    Alignment.bottomCenter,
        colors: [Color(0xFF9B6B3A), AppTheme.shelfWood, AppTheme.shelfEdge],
      ).createShader(Rect.fromLTWH(0, size.height * 0.78, size.width, 20));

    // Draw shelf board
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.78, size.width, 20),
      shelfPaint,
    );

    // Draw shelf supports
    final supportPaint = Paint()..color = AppTheme.shelfEdge;
    canvas.drawRect(Rect.fromLTWH(10, size.height * 0.3, 8, size.height * 0.5), supportPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 18, size.height * 0.3, 8, size.height * 0.5), supportPaint);

    // Draw a few ghost/faded book outlines to suggest emptiness
    final ghostPaint = Paint()
      ..color = AppTheme.surfaceVariant.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final ghostBorderPaint = Paint()
      ..color       = AppTheme.surfaceVariant.withOpacity(0.15)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1;

    final bookPositions = [40.0, 100.0, 160.0, 210.0];
    final bookHeights   = [100.0, 120.0, 90.0, 110.0];
    final bookWidths    = [35.0, 30.0, 38.0, 28.0];

    for (var i = 0; i < bookPositions.length; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bookPositions[i],
          size.height * 0.78 - bookHeights[i],
          bookWidths[i],
          bookHeights[i],
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, ghostPaint);
      canvas.drawRRect(rect, ghostBorderPaint);
    }

    // Question mark on center ghost book
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          fontFamily: 'Georgia',
          color:      Color(0x44FFFFFF),
          fontSize:   32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height * 0.78 / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
