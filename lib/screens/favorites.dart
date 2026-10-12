import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../bloc/properties_bloc.dart';
import '../bloc/properties_state.dart';
import 'property_detail.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, favState) {
          return BlocBuilder<PropertiesBloc, PropertiesState>(
            builder: (context, propertiesState) {
              final favorites = propertiesState.properties
                  .where((p) => favState.favoritePropertyIds.contains(p.id))
                  .toList();

              if (favorites.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No favorites added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final property = favorites[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: property.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                property.coverImageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    property.icon,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                property.icon,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                      title: Text(
                        property.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${property.city} • ${property.priceLabel}',
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.star,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          context.read<FavoritesBloc>().add(
                            ToggleFavoriteEvent(property.id),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              propertyId: property.id,
                              heroTitle: property.title,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
