import 'package:flutter/material.dart';
import 'package:scamurai/presentation/widgets/pie_chart_painter.dart';

class ManualPieChart extends StatefulWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const ManualPieChart({required this.data, required this.colors, Key? key})
      : super(key: key);

  @override
  _ManualPieChartState createState() => _ManualPieChartState();
}

class _ManualPieChartState extends State<ManualPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration
    );

    // Define the animation
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0.0, (sum, value) => sum + value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.5; // Dynamically adjust size
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pie Chart with Animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return SizedBox(
                  height: size,
                  width: size,
                  child: CustomPaint(
                    painter: PieChartPainter(
                      values: widget.data.values.toList(),
                      colors: widget.colors,
                      labels: widget.data.keys.toList(),
                      centerText: "Total\n${total.toInt()}",
                      animationValue: _animation.value, // Pass animation value
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Legend
            Wrap(
              spacing: 15,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: widget.data.keys.map((key) {
                final index = widget.data.keys.toList().indexOf(key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: widget.colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "$key (${widget.data[key]?.toInt() ?? 0})",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
