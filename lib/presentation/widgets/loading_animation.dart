import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(); // Repeats the animation indefinitely.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Creating a delay for each dot to bounce sequentially.
            final value = (index * 0.2) + _controller.value;
            final offset = (value % 1.0).abs(); // Keeps value in 0-1 range.
            return Transform.translate(
              offset: Offset(0, -10 * (1 - offset)), // Adjust bounce height.
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 10,
            width: 10,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
