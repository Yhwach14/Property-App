import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/properties_repository.dart';
import 'properties_event.dart';
import 'properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  final PropertiesRepository _repository;

  PropertiesBloc(this._repository) : super(const PropertiesState()) {
    on<LoadPropertiesEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPropertiesEvent event,
    Emitter<PropertiesState> emit,
  ) async {
    emit(state.copyWith(status: PropertiesStatus.loading));
    try {
      final properties = await _repository.fetchProperties();
      emit(
        state.copyWith(
          status: PropertiesStatus.success,
          properties: properties,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PropertiesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
