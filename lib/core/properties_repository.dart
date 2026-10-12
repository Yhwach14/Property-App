import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/property.dart';
import 'dart:io';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class PropertiesRepository {
  final http.Client _client;
  PropertiesRepository({http.Client? client})
    : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 8);

  Future<List<Property>> fetchProperties() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/properties',
    ).replace(queryParameters: {'pageSize': '50'});

    final response = await _get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        (body['error']?['message'] as String?) ?? 'Failed to load properties',
      );
    }

    final data = body['data'] as List;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyDetail> fetchPropertyDetail(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/properties/$id');
    final response = await _get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        (body['error']?['message'] as String?) ?? 'Failed to load property',
      );
    }

    return PropertyDetail.fromJson(body);
  }

  Future<http.Response> _get(Uri uri) {
    return _client
        .get(uri)
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(
            0,
            'Could not reach the server. Please try again.',
          ),
        );
  }

  Future<List<Property>> fetchMyProperties({required String token}) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/me/properties',
    ).replace(queryParameters: {'pageSize': '50'});

    final response = await _client
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        (body['error']?['message'] as String?) ??
            'Failed to load your properties',
      );
    }

    final data = body['data'] as List;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyDetail> fetchMyPropertyDetail(
    String id, {
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/me/properties/$id');
    final response = await _client
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        (body['error']?['message'] as String?) ?? 'Failed to load property',
      );
    }
    return PropertyDetail.fromJson(body);
  }

  Future<List<Amenity>> fetchAmenities() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/amenities');
    final response = await _client
        .get(uri)
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Failed to load amenities');
    }
    final data = jsonDecode(response.body) as List;
    return data
        .map((e) => Amenity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyDetail> createProperty(
    Map<String, dynamic> payload, {
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/properties');
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(response.statusCode, _extractError(body));
    }
    return PropertyDetail.fromJson(body);
  }

  Future<PropertyDetail> updateProperty(
    String id,
    Map<String, dynamic> payload, {
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/properties/$id');
    final response = await _client
        .patch(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, _extractError(body));
    }
    return PropertyDetail.fromJson(body);
  }

  Future<void> deleteProperty(String id, {required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/properties/$id');
    final response = await _client
        .delete(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );

    if (response.statusCode != 204) {
      throw ApiException(response.statusCode, 'Failed to delete property');
    }
  }

  Future<PropertyImage> uploadImage(
    String propertyId,
    File file, {
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/properties/$propertyId/images');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send().timeout(
      _timeout,
      onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
    );
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(response.statusCode, _extractError(body));
    }
    return PropertyImage.fromJson(body);
  }

  Future<PropertyImage> setImageCover(
    String propertyId,
    String imageId, {
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/properties/$propertyId/images/$imageId',
    );
    final response = await _client
        .patch(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'isCover': true}),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, _extractError(body));
    }
    return PropertyImage.fromJson(body);
  }

  Future<void> deleteImage(
    String propertyId,
    String imageId, {
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/properties/$propertyId/images/$imageId',
    );
    final response = await _client
        .delete(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(0, 'Could not reach the server.'),
        );

    if (response.statusCode != 204) {
      throw ApiException(response.statusCode, 'Failed to delete image');
    }
  }

  String _extractError(Map<String, dynamic> body) {
    final error = body['error'] as Map<String, dynamic>?;
    if (error == null) return 'Something went wrong';
    final details = error['details'];
    if (details is List && details.isNotEmpty) {
      return details.join('\n');
    }
    return (error['message'] as String?) ?? 'Something went wrong';
  }
}
