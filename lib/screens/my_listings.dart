import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/my_properties_bloc.dart';
import '../bloc/my_properties_event.dart';
import '../bloc/my_properties_state.dart';
import '../core/properties_repository.dart';
import 'manage_photos.dart';
import 'property_form.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MyPropertiesBloc(PropertiesRepository(), context.read<AuthBloc>())
            ..add(LoadMyPropertiesEvent()),
      child: const _MyListingsView(),
    );
  }
}

class _MyListingsView extends StatelessWidget {
  const _MyListingsView();

  Future<void> _openCreateForm(BuildContext context) async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PropertyFormScreen()));
    if (changed == true && context.mounted) {
      context.read<MyPropertiesBloc>().add(LoadMyPropertiesEvent());
    }
  }

  Future<void> _openEditForm(BuildContext context, String propertyId) async {
    final token = context.read<AuthBloc>().state.token;
    if (token == null) return;

    try {
      final repository = PropertiesRepository();
      final detail = await repository.fetchMyPropertyDetail(
        propertyId,
        token: token,
      );
      if (!context.mounted) return;

      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PropertyFormScreen(existing: detail)),
      );
      if (changed == true && context.mounted) {
        context.read<MyPropertiesBloc>().add(LoadMyPropertiesEvent());
      }
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openPhotos(
    BuildContext context,
    String propertyId,
    String propertyTitle,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManagePhotosScreen(
          propertyId: propertyId,
          propertyTitle: propertyTitle,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String propertyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text(
          'This removes the listing from the public site. This cannot be undone from the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final token = context.read<AuthBloc>().state.token;
    if (token == null) return;

    try {
      await PropertiesRepository().deleteProperty(propertyId, token: token);
      if (!context.mounted) return;
      context.read<MyPropertiesBloc>().add(LoadMyPropertiesEvent());
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: BlocBuilder<MyPropertiesBloc, MyPropertiesState>(
        builder: (context, state) {
          if (state.status == MyPropertiesStatus.loading ||
              state.status == MyPropertiesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MyPropertiesStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? 'Something went wrong',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<MyPropertiesBloc>().add(
                        LoadMyPropertiesEvent(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.properties.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home_work_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "You haven't listed any properties yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openCreateForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add your first listing'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<MyPropertiesBloc>().add(LoadMyPropertiesEvent()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.properties.length,
              itemBuilder: (context, index) {
                final property = state.properties[index];
                final isPublished = property.isPublished ?? false;

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
                    subtitle: Row(
                      children: [
                        Text('${property.city} • ${property.priceLabel}'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isPublished
                                ? Colors.green.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPublished ? 'Live' : 'Draft',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPublished
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _openEditForm(context, property.id);
                            break;
                          case 'photos':
                            _openPhotos(context, property.id, property.title);
                            break;
                          case 'delete':
                            _confirmDelete(context, property.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'photos',
                          child: Text('Manage photos'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add listing'),
      ),
    );
  }
}
