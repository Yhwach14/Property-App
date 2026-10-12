import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/properties_repository.dart';
import 'property_detail_event.dart';
import 'property_detail_state.dart';

class PropertyDetailBloc
    extends Bloc<PropertyDetailEvent, PropertyDetailState> {
  final PropertiesRepository _repository;

  PropertyDetailBloc(this._repository) : super(const PropertyDetailState()) {
    on<LoadPropertyDetailEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPropertyDetailEvent event,
    Emitter<PropertyDetailState> emit,
  ) async {
    emit(const PropertyDetailState(status: PropertyDetailStatus.loading));
    try {
      final property = await _repository.fetchPropertyDetail(event.propertyId);
      emit(
        PropertyDetailState(
          status: PropertyDetailStatus.success,
          property: property,
        ),
      );
    } catch (e) {
      emit(
        PropertyDetailState(
          status: PropertyDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
