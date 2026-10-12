import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String propertyId;
  const ToggleFavoriteEvent(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class ClearFavoritesEvent extends FavoritesEvent {}
