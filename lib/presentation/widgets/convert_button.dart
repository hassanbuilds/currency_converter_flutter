import 'package:flutter/material.dart';

class ConvertButton extends StatelessWidget {
  const ConvertButton({
    super.key,
    required this.isTablet,
    required this.onPressed, // 🆕 ADDED
    required this.isLoading, // 🆕 ADDED
    required this.isOffline, // 🆕 ADDED
  });

  final bool isTablet;
  final VoidCallback onPressed; // 🆕 ADDED
  final bool isLoading; // 🆕 ADDED
  final bool isOffline; // 🆕 ADDED

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final double fontSize = isTablet ? 20 : (width < 360 ? 14 : 16);
    final double paddingY = isTablet ? 18 : 12;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed, // 🆕 ADDED loading state
            icon:
                isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                    : Icon(
                      isOffline
                          ? Icons.wifi_off
                          : Icons.currency_exchange, // 🆕 DIFFERENT ICON
                      size: 22,
                    ),
            label:
                isLoading
                    ? const Text('Converting...')
                    : Text(
                      isOffline ? 'Convert (Offline)' : 'Convert',
                    ), // 🆕 DIFFERENT TEXT
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: paddingY),
              textStyle: TextStyle(fontSize: fontSize),
              minimumSize: Size(double.infinity, isTablet ? 60 : 48),
              backgroundColor:
                  isOffline
                      ? Colors.grey
                      : null, // 🆕 DIFFERENT COLOR WHEN OFFLINE
              foregroundColor:
                  isOffline ? Colors.white : null, // 🆕 TEXT COLOR WHEN OFFLINE
            ),
          ),
        ),
        // 🆕 OFFLINE INFO TEXT
        if (isOffline)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Using cached exchange rates',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
