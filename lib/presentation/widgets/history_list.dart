import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;

  const HistoryList({super.key, required this.history, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? size.width * 0.02 : 0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conversion History',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: isTablet ? 24 : 20,
                ),
                label: Text(
                  "Clear",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
            ],
          ),
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 8),
                child: Text(
                  'No history yet.',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder:
                  (context, index) => Card(
                    elevation: isTablet ? 5 : 3,
                    margin: EdgeInsets.symmetric(
                      vertical: isTablet ? 6 : 4,
                      horizontal: isTablet ? 4 : 0,
                    ),
                    child: ListTile(
                      leading: Icon(Icons.history, size: isTablet ? 26 : 20),
                      title: Text(
                        history[index],
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
