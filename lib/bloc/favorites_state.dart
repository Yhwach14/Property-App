import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final Set<String> favoritePropertyIds;

  const FavoritesState({this.favoritePropertyIds = const {}});

  bool isFavorite(String propertyId) =>
      favoritePropertyIds.contains(propertyId);

  FavoritesState copyWith({Set<String>? favoritePropertyIds}) {
    return FavoritesState(
      favoritePropertyIds: favoritePropertyIds ?? this.favoritePropertyIds,
    );
  }

  @override
  List<Object?> get props => [favoritePropertyIds];
}
