import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class ToggleCategoryFilterEvent extends CategoryEvent {
  final String categoryId;

  const ToggleCategoryFilterEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ClearAllFiltersEvent extends CategoryEvent {}
