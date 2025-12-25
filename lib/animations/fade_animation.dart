import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;

  const FadeAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (_, value, child) =>
          Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
