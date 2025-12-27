import 'package:flutter/material.dart';

class ConvertButton extends StatelessWidget {
  const ConvertButton({
    super.key,
    required this.isTablet,
    required this.onPressed,
    required this.isLoading,
    required this.isOffline,
  });

  final bool isTablet;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOffline;

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
            onPressed: isLoading ? null : onPressed,
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
                      isOffline ? Icons.wifi_off : Icons.currency_exchange,
                      size: 22,
                    ),
            label:
                isLoading
                    ? const Text('Converting...')
                    : Text(isOffline ? 'Convert (Offline)' : 'Convert'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: paddingY),
              textStyle: TextStyle(fontSize: fontSize),
              minimumSize: Size(double.infinity, isTablet ? 60 : 48),
              backgroundColor: isOffline ? Colors.grey : null,
              foregroundColor: isOffline ? Colors.white : null,
            ),
          ),
        ),

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
