import 'dart:math';
import 'package:flutter/material.dart';

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;
  final String centerText;
  final double animationValue; // Animation progress (0.0 to 1.0)

  PieChartPainter({
    required this.values,
    required this.colors,
    required this.labels,
    this.centerText = "",
    this.animationValue = 1.0, // Default to fully drawn
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final total = values.fold(0.0, (sum, value) => sum + value);
    double startAngle = -pi / 2;

    // Draw shadow for the pie chart
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      shadowPaint,
    );

    // Draw each segment
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) *
          2 *
          pi *
          animationValue; // Scale by animationValue
      paint.color = colors[i];

      // Draw the segment
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw labels only when the segment is fully drawn
      if (animationValue == 1.0) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = size.width / 2.5; // Adjust label position
        final labelX = size.width / 2 + labelRadius * cos(labelAngle);
        final labelY = size.height / 2 + labelRadius * sin(labelAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: "${(values[i] / total * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
              labelX - textPainter.width / 2, labelY - textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center text
    final centerTextPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    centerTextPainter.paint(
      canvas,
      Offset(
        size.width / 2 - centerTextPainter.width / 2,
        size.height / 2 - centerTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
