import 'package:flutter/material.dart';

class ConversionResultCard extends StatelessWidget {
  final String result;

  const ConversionResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Card(
      elevation: isTablet ? 6 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? size.width * 0.02 : 0,
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Text(
          result,
          style: TextStyle(
            fontSize: isTablet ? 22 : 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
