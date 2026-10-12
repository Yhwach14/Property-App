import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';
import 'login.dart';
import 'my_listings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showResetFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Favorites'),
        content: const Text(
          'Are you sure you want to clear all your saved properties?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<FavoritesBloc>().add(ClearFavoritesEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites have been cleared.')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hotel_rounded, size: 32),
            SizedBox(width: 12),
            Text('Hotel Booking App'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developed by Yhwach14',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A modern hotel booking application built with Flutter and BLoC state management.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                final user = state.user!;
                final canManageListings =
                    user.role == 'OWNER' || user.role == 'ADMIN';
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(user.fullName),
                      subtitle: Text('${user.email} • ${user.role}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: 'Log out',
                        onPressed: () =>
                            context.read<AuthBloc>().add(LoggedOut()),
                      ),
                    ),
                    if (canManageListings)
                      ListTile(
                        leading: const Icon(Icons.home_work_outlined),
                        title: const Text('Manage Listings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MyListingsScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }

              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Log in'),
                subtitle: const Text('Manage your listings as an owner'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              );
            },
          ),
          const Divider(),

          // App Settings Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                secondary: Icon(
                  state.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  state.isDarkMode
                      ? 'Dark theme enabled'
                      : 'Light theme enabled',
                ),
                value: state.isDarkMode,
                onChanged: (_) {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
          const Divider(),

          // Data Management Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Reset Favorites',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Clear all saved properties'),
            onTap: () => _showResetFavoritesDialog(context),
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            subtitle: const Text('Version 1.0.0 & Developer Info'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }
}
