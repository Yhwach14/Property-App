import 'package:flutter/material.dart';

class PropertyImage {
  final String id;
  final String url;
  final int sortOrder;
  final bool isCover;

  PropertyImage({
    required this.id,
    required this.url,
    required this.sortOrder,
    required this.isCover,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) => PropertyImage(
    id: json['id'] as String,
    url: json['url'] as String,
    sortOrder: json['sortOrder'] as int,
    isCover: json['isCover'] as bool,
  );
}

class Amenity {
  final String id;
  final String slug;
  final String name;

  Amenity({required this.id, required this.slug, required this.name});

  factory Amenity.fromJson(Map<String, dynamic> json) => Amenity(
    id: json['id'] as String,
    slug: json['slug'] as String,
    name: json['name'] as String,
  );
}

class OwnerSummary {
  final String id;
  final String firstName;
  final String lastName;

  OwnerSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory OwnerSummary.fromJson(Map<String, dynamic> json) => OwnerSummary(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
  );
}

/// List-item shape, as returned by `GET /properties` and `GET /me/properties`.
class Property {
  final String id;
  final String title;
  final String type; // APARTMENT, VILLA, MOTEL, CABIN, OTHER
  final num price;
  final String currency;
  final String pricePeriod; // PER_NIGHT, PER_MONTH
  final String city;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final String? coverImageUrl;
  final bool? isPublished;

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.currency,
    required this.pricePeriod,
    required this.city,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    this.coverImageUrl,
    this.isPublished,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      price: json['price'] as num,
      currency: json['currency'] as String,
      pricePeriod: json['pricePeriod'] as String,
      city: json['city'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      maxGuests: json['maxGuests'] as int,
      coverImageUrl: json['coverImageUrl'] as String?,
      isPublished: json['isPublished'] as bool?,
    );
  }

  /// Maps the API's type enum to the shorthand ids already used by
  /// CategoryItem ('apt', 'villa', ...) so the existing filter keeps working.
  String get categoryId {
    switch (type) {
      case 'APARTMENT':
        return 'apt';
      case 'VILLA':
        return 'villa';
      case 'MOTEL':
        return 'motel';
      case 'CABIN':
        return 'cabin';
      default:
        return 'other';
    }
  }

  IconData get icon {
    switch (type) {
      case 'APARTMENT':
        return Icons.apartment_rounded;
      case 'VILLA':
        return Icons.villa_rounded;
      case 'MOTEL':
        return Icons.hotel_rounded;
      case 'CABIN':
        return Icons.cabin_rounded;
      default:
        return Icons.home_work_rounded;
    }
  }

  String get priceLabel =>
      '\$${price.toStringAsFixed(0)}/${pricePeriod == 'PER_NIGHT' ? 'night' : 'month'}';
}

/// Full detail shape, as returned by `GET /properties/:id` and
/// `GET /me/properties/:id`.
class PropertyDetail {
  final String id;
  final String title;
  final String type;
  final num price;
  final String currency;
  final String pricePeriod;
  final String city;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<Amenity> amenities;
  final List<PropertyImage> images;
  final String contactEmail;
  final OwnerSummary owner;
  final String? contactPhone;
  final bool? isPublished;

  PropertyDetail({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.currency,
    required this.pricePeriod,
    required this.city,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.amenities,
    required this.images,
    required this.contactEmail,
    required this.owner,
    this.contactPhone,
    this.isPublished,
  });

  factory PropertyDetail.fromJson(Map<String, dynamic> json) {
    return PropertyDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      price: json['price'] as num,
      currency: json['currency'] as String,
      pricePeriod: json['pricePeriod'] as String,
      city: json['city'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      maxGuests: json['maxGuests'] as int,
      description: json['description'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List)
          .map((e) => Amenity.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List)
          .map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      contactEmail: json['contactEmail'] as String,
      owner: OwnerSummary.fromJson(json['owner'] as Map<String, dynamic>),
      contactPhone: json['contactPhone'] as String?,
      isPublished: json['isPublished'] as bool?,
    );
  }

  String get priceLabel =>
      '\$${price.toStringAsFixed(0)}/${pricePeriod == 'PER_NIGHT' ? 'night' : 'month'}';

  PropertyImage? get coverImage => images.isEmpty
      ? null
      : images.reduce((a, b) => a.sortOrder <= b.sortOrder ? a : b);
}
