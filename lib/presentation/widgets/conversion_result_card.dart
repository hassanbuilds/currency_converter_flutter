import 'package:flutter/material.dart';

class ConversionResultCard extends StatefulWidget {
  final String result;
  final double? previousValue;

  const ConversionResultCard({
    super.key,
    required this.result,
    this.previousValue,
  });

  @override
  State<ConversionResultCard> createState() => _ConversionResultCardState();
}

class _ConversionResultCardState extends State<ConversionResultCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.result.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Card(
      elevation: isTablet ? 6 : 4,
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? size.width * 0.02 : 0,
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: Text(
            widget.result,
            key: ValueKey(widget.result),
            style: TextStyle(
              fontSize: isTablet ? 22 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.white, // ✅ White for contrast
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
