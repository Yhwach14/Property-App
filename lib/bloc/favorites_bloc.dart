import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/favorites_storage.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesStorage _storage;

  FavoritesBloc(this._storage) : super(const FavoritesState()) {
    on<LoadFavoritesEvent>(_onLoad);
    on<ToggleFavoriteEvent>(_onToggle);
    on<ClearFavoritesEvent>(_onClear);
  }

  Future<void> _onLoad(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final ids = await _storage.load();
    emit(state.copyWith(favoritePropertyIds: ids));
  }

  Future<void> _onToggle(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final updated = Set<String>.from(state.favoritePropertyIds);
    if (updated.contains(event.propertyId)) {
      updated.remove(event.propertyId);
    } else {
      updated.add(event.propertyId);
    }
    emit(state.copyWith(favoritePropertyIds: updated));
    await _storage.save(updated);
  }

  Future<void> _onClear(
    ClearFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesState(favoritePropertyIds: {}));
    await _storage.save({});
  }
}
