import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  bool get isDarkMode => themeMode == ThemeMode.dark;

  @override
  List<Object?> get props => [themeMode];
}
