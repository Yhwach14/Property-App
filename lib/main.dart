import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/category_bloc.dart';
import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_event.dart';
import 'bloc/theme_bloc.dart';
import 'bloc/theme_state.dart';
import 'bloc/properties_bloc.dart';
import 'bloc/properties_event.dart';
import 'core/auth_storage.dart';
import 'core/favorites_storage.dart';
import 'core/properties_repository.dart';
import 'screens/taps.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CategoryBloc()),
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(
          create: (context) =>
              FavoritesBloc(FavoritesStorage())..add(LoadFavoritesEvent()),
        ),
        BlocProvider(
          create: (context) =>
              PropertiesBloc(PropertiesRepository())
                ..add(LoadPropertiesEvent()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(AuthStorage())..add(AppStarted()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hotel Booking App',
          themeMode: state.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.cyan[50],
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.cyan[50],
          ),
          home: const Tapscreen(),
        );
      },
    );
  }
}
