import 'package:flutter/material.dart';

class CategoryPropertiesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryPropertiesScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Properties for: $categoryTitle',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Filter Key (CSV/Database Column): "$categoryId"',
              style: TextStyle(color: Colors.grey[600]),
            ),
            // Later, your API/Database fetch will query using `categoryId`
          ],
        ),
      ),
    );
  }
}
