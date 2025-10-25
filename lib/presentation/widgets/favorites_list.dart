// lib/presentation/widgets/favorites_list.dart
import 'package:flutter/material.dart';

class FavoritesList extends StatelessWidget {
  final List<String> favorites;
  final void Function(int index) onRemove;

  const FavoritesList({
    super.key,
    required this.favorites,
    required this.onRemove,
    required void Function(dynamic pair) onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Currency Pairs',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            String fav = favorites[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(
                  fav,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
