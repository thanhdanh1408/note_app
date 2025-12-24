import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

enum LoadingStyle { circular, overlay }

class LoadingWidget extends StatelessWidget {
  final LoadingStyle style;
  final String? message;

  const LoadingWidget({
    super.key,
    this.style = LoadingStyle.circular,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (style == LoadingStyle.overlay) {
      return Container(
        color: Colors.black54,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTextStyles.bodyMedium),
          ]
        ],
      ),
    );
  }
}
