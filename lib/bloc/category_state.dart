import 'package:equatable/equatable.dart';

class CategoryState extends Equatable {
  final Set<String> selectedCategoryIds; // Set allows multiple selected types

  const CategoryState({this.selectedCategoryIds = const {}});

  CategoryState copyWith({Set<String>? selectedCategoryIds}) {
    return CategoryState(
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
    );
  }

  @override
  List<Object?> get props => [selectedCategoryIds];
}
