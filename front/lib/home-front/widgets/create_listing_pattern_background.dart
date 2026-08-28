import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Subtle repeating hexagon lattice + a faint oversized star watermark,
/// used behind the Create Listing flow's pages. Pure CustomPainter — no
/// image asset needed, so it scales cleanly to any screen size.
///
/// Usage: wrap a Scaffold's body content —
///   body: CreateListingPatternBackground(child: yourColumnOrStack)
class CreateListingPatternBackground extends StatelessWidget {
  final Widget child;

  const CreateListingPatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _HexPatternPainter(),
              size: Size.infinite,
            ),
          ),
        ),
        Positioned(
          left: -60,
          bottom: -40,
          child: Icon(
            Icons.star,
            size: 260,
            color: const Color(0xFFEFE4D0).withOpacity(0.5),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _HexPatternPainter extends CustomPainter {
  const _HexPatternPainter();

  static const double _hexSize = 22;
  static const Color _lineColor = Color(0xFFE7DCCB);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final hexHeight = _hexSize * math.sqrt(3);
    final colSpacing = _hexSize * 1.5;
    final rowSpacing = hexHeight;

    final cols = (size.width / colSpacing).ceil() + 2;
    final rows = (size.height / rowSpacing).ceil() + 2;

    for (int col = -1; col < cols; col++) {
      for (int row = -1; row < rows; row++) {
        final x = col * colSpacing;
        final y = row * rowSpacing + (col.isOdd ? rowSpacing / 2 : 0);
        _drawHexagon(canvas, paint, Offset(x, y), _hexSize);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final point = Offset(
        center.dx + size * math.cos(angle),
        center.dy + size * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexPatternPainter oldDelegate) => false;
}