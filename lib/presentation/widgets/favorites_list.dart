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

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? size.width * 0.02 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorite Currency Pairs',
            style: TextStyle(
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              String fav = favorites[index];
              return Card(
                elevation: isTablet ? 5 : 3,
                margin: EdgeInsets.symmetric(
                  vertical: isTablet ? 8 : 4,
                  horizontal: isTablet ? 4 : 0,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: isTablet ? 30 : 24,
                  ),
                  title: Text(
                    fav,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 14,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: isTablet ? 26 : 22,
                    ),
                    onPressed: () => onRemove(index),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
