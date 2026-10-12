import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../bloc/properties_bloc.dart';
import '../bloc/properties_event.dart';
import '../bloc/properties_state.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../models/category.dart';
import 'property_detail.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _showFilterModal(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        // Explicitly bind the parent CategoryBloc to the modal's state listener
        return BlocBuilder<CategoryBloc, CategoryState>(
          bloc: BlocProvider.of<CategoryBloc>(parentContext),
          builder: (ctx, state) {
            final selected = state.selectedCategoryIds;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Stays',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selected.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            parentContext.read<CategoryBloc>().add(
                              ClearAllFiltersEvent(),
                            );
                          },
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...categories.map((category) {
                    final isChecked = selected.contains(category.id);

                    return CheckboxListTile(
                      activeColor: Theme.of(parentContext).primaryColor,
                      title: Text(category.title),
                      secondary: Icon(category.icon),
                      value: isChecked,
                      onChanged: (_) {
                        parentContext.read<CategoryBloc>().add(
                          ToggleCategoryFilterEvent(category.id),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(parentContext).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(modalContext),
                      child: Text(
                        selected.isEmpty
                            ? 'Showing All Listings'
                            : 'Apply Filter (${selected.length})',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PropertiesBloc, PropertiesState>(
        builder: (context, propertiesState) {
          return BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, categoryState) {
              if (propertiesState.status == PropertiesStatus.loading ||
                  propertiesState.status == PropertiesStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (propertiesState.status == PropertiesStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          propertiesState.errorMessage ??
                              'Something went wrong',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<PropertiesBloc>().add(
                            LoadPropertiesEvent(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final selected = categoryState.selectedCategoryIds;
              final displayedProperties = selected.isEmpty
                  ? propertiesState.properties
                  : propertiesState.properties
                        .where((p) => selected.contains(p.categoryId))
                        .toList();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Where do you want to stay?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: displayedProperties.isEmpty
                          ? const Center(
                              child: Text(
                                'No listings found for selected filters',
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayedProperties.length,
                              itemBuilder: (context, index) {
                                final property = displayedProperties[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: property.coverImageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              property.coverImageUrl!,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  CircleAvatar(
                                                    radius: 24,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.1),
                                                    child: Icon(
                                                      property.icon,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
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
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                    title: Text(
                                      property.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${property.city} • ${property.priceLabel} • ${property.bedrooms} bed',
                                    ),
                                    trailing:
                                        BlocBuilder<
                                          FavoritesBloc,
                                          FavoritesState
                                        >(
                                          builder: (context, favState) {
                                            final isFav = favState.isFavorite(
                                              property.id,
                                            );
                                            return IconButton(
                                              icon: Icon(
                                                isFav
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: isFav
                                                    ? Theme.of(
                                                        context,
                                                      ).primaryColor
                                                    : Colors.grey,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<FavoritesBloc>()
                                                    .add(
                                                      ToggleFavoriteEvent(
                                                        property.id,
                                                      ),
                                                    );
                                              },
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
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterModal(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}
