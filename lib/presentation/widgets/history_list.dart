import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;
  final VoidCallback onClear;

  const HistoryList({super.key, required this.history, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Conversion History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Clear", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        if (history.isEmpty)
          Center(
            child: Text(
              'No history yet.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder:
                (context, index) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(history[index]),
                  ),
                ),
          ),
      ],
    );
  }
}
