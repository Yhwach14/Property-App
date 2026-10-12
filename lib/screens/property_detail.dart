import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/property_detail_bloc.dart';
import '../bloc/property_detail_event.dart';
import '../bloc/property_detail_state.dart';
import '../core/properties_repository.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;
  final String? heroTitle;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.heroTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PropertyDetailBloc(PropertiesRepository())
            ..add(LoadPropertyDetailEvent(propertyId)),
      child: Scaffold(
        appBar: AppBar(title: Text(heroTitle ?? 'Property details')),
        body: BlocBuilder<PropertyDetailBloc, PropertyDetailState>(
          builder: (context, state) {
            if (state.status == PropertyDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PropertyDetailStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final property = state.property!;
            final cover = property.coverImage;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cover != null)
                    Image.network(
                      cover.url,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 240,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.city,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          property.priceLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.bed,
                              label: '${property.bedrooms} bed',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.bathtub,
                              label: '${property.bathrooms} bath',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.people,
                              label: '${property.maxGuests} guests',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'About this place',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(property.description),
                        if (property.amenities.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: property.amenities
                                .map((a) => Chip(label: Text(a.name)))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Contact the owner'),
                            subtitle: Text(property.contactEmail),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy email',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: property.contactEmail),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email copied')),
                                );
                              },
                            ),
                          ),
                        ),
                        if (property.contactPhone != null) ...[
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text('Call the owner'),
                              subtitle: Text(property.contactPhone!),
                              trailing: IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy phone number',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: property.contactPhone!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Phone number copied'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
