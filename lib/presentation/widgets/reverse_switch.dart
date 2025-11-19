import 'package:flutter/material.dart';

class ReverseSwitch extends StatelessWidget {
  const ReverseSwitch({
    super.key,
    required this.onPressed,
    this.isTablet = false,
  });

  final VoidCallback onPressed;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.swap_vert),
      label: const Text('Reverse'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        textStyle: TextStyle(fontSize: isTablet ? 18 : 14),
      ),
    );
  }
}
