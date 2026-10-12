import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    size: 32,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.count} Places',
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
