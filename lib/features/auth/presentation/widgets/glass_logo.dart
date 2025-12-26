import 'dart:ui';
import 'package:flutter/material.dart';

class GlassLogo extends StatelessWidget {
  final double size;

  const GlassLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Frosted blur layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Cutout and Sheen layer
            CustomPaint(
              size: Size(size, size),
              painter: _GlassLogoPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 1. Define the Tick Path
    final tickPath = Path();
    final w = size.width * 0.35;
    final h = size.height * 0.35;
    
    tickPath.moveTo(centerX - w * 0.3, centerY + h * 0.1);
    tickPath.lineTo(centerX - w * 0.05, centerY + h * 0.4);
    tickPath.lineTo(centerX + w * 0.4, centerY - h * 0.35);

    // 2. Prepare the cutout using Layer/Clear blend mode
    // We draw the "glass" body, then punch the hole.
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Draw glass tinting
    final tintPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), tintPaint);

    // Punch the hole (Tick)
    final cutoutPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.clear;
    
    canvas.drawPath(tickPath, cutoutPaint);
    canvas.restore();

    // 3. Add Liquid Sheen / Highlights (on top)
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromLTWH(size.width * 0.1, size.height * 0.05, size.width * 0.8, size.height * 0.4))
      ..style = PaintingStyle.fill;

    // Drawing a thin "reflection" ellipse at the top
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.6, size.height * 0.2),
      sheenPaint,
    );

    // 4. Subtle Rim Light
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5), rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
