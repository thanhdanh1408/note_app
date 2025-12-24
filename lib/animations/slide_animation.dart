import 'package:flutter/material.dart';

class SlideAnimation extends StatelessWidget {
  final Widget child;

  const SlideAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: const Offset(0, 0.2), end: Offset.zero),
      builder: (_, value, child) => Transform.translate(
        offset: value * 100,
        child: child,
      ),
      child: child,
    );
  }
}
