import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final int count;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.count,
  });
}

// Global list of available categories
const List<CategoryItem> categories = [
  CategoryItem(
    id: 'apt',
    title: 'Apartment',
    icon: Icons.apartment,
    count: 1240,
  ),
  CategoryItem(id: 'villa', title: 'Villa', icon: Icons.villa, count: 450),
  CategoryItem(id: 'motel', title: 'Motel', icon: Icons.hotel, count: 310),
  CategoryItem(id: 'cabin', title: 'Cabin', icon: Icons.cabin, count: 180),
  CategoryItem(
    id: 'other',
    title: 'Other Stays',
    icon: Icons.more_horiz,
    count: 95,
  ),
];
