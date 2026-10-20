import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';

/// Coretan abstrak tipis warna secondaryColor (kuning).
/// Hanya beberapa garis lengkung + lingkaran kecil, tidak ramai.
class DoodleTexture extends StatelessWidget {
  const DoodleTexture({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(painter: _DoodlePainter()),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  const _DoodlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.secondaryColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final softLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(-size.width * 0.25, -40, size.width * 0.5, 180),
      0.3, 2.2, false, line,
    );
    canvas.drawArc(
      Rect.fromLTWH(
          size.width * 0.72, size.height * 0.30, size.width * 0.5, 200),
      2.4, 2.0, false, softLine,
    );
    final zig = Path()
      ..moveTo(size.width * 0.06, size.height * 0.78)
      ..lineTo(size.width * 0.14, size.height * 0.73)
      ..lineTo(size.width * 0.22, size.height * 0.79)
      ..lineTo(size.width * 0.30, size.height * 0.74);
    canvas.drawPath(zig, line);
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.86),
      Offset(size.width * 0.94, size.height * 0.78),
      line,
    );
    final dot = Paint()
      ..color = AppColors.secondaryColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.16, size.height * 0.22), 3, dot);
    canvas.drawCircle(
        Offset(size.width * 0.86, size.height * 0.16), 2.5, dot);
    canvas.drawCircle(
        Offset(size.width * 0.90, size.height * 0.62), 3, dot);
    canvas.drawCircle(
        Offset(size.width * 0.10, size.height * 0.58), 2.5, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
