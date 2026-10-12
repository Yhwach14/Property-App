import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/category_bloc.dart';
import 'categories.dart';
import 'settings.dart';
import 'favorites.dart';

class Tapscreen extends StatefulWidget {
  const Tapscreen({super.key});

  @override
  State<Tapscreen> createState() {
    return _TapscreenState();
  }
}

class _TapscreenState extends State<Tapscreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const CategoriesScreen();

    if (_selectedPageIndex == 1) {
      activePage = const FavoritesScreen();
    }
    if (_selectedPageIndex == 2) {
      activePage = const SettingsScreen();
    }

    return BlocProvider(
      create: (context) => CategoryBloc(),
      child: Scaffold(
        // SafeArea prevents content from hiding behind the phone notch/status bar
        body: SafeArea(child: activePage),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              activeIcon: Icon(Icons.star),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
