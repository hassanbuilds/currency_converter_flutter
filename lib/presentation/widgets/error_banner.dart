import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  final bool isWarning;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWarning ? Colors.orange : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber : Icons.error_outline,
            color: isWarning ? Colors.orange[800] : Colors.red[800],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isWarning ? Colors.orange[800] : Colors.red[800],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: isWarning ? Colors.orange[800] : Colors.red[800],
              size: 18,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
