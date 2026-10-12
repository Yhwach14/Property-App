import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryState()) {
    on<ToggleCategoryFilterEvent>(_onToggleCategory);
    on<ClearAllFiltersEvent>(_onClearAll);
  }

  void _onToggleCategory(
    ToggleCategoryFilterEvent event,
    Emitter<CategoryState> emit,
  ) {
    final updated = Set<String>.from(state.selectedCategoryIds);
    if (updated.contains(event.categoryId)) {
      updated.remove(event.categoryId);
    } else {
      updated.add(event.categoryId);
    }
    emit(state.copyWith(selectedCategoryIds: updated));
  }

  void _onClearAll(ClearAllFiltersEvent event, Emitter<CategoryState> emit) {
    emit(const CategoryState(selectedCategoryIds: {}));
  }
}
