import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width > 600;

    final double indicatorSize = size ?? (isTablet ? 80 : 50);

    return Center(
      child: SizedBox(
        height: indicatorSize,
        width: indicatorSize,
        child: const CircularProgressIndicator(strokeWidth: 4),
      ),
    );
  }
}
