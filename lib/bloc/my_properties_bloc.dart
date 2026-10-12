import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/properties_repository.dart';
import 'auth_bloc.dart';
import 'my_properties_event.dart';
import 'my_properties_state.dart';

class MyPropertiesBloc extends Bloc<MyPropertiesEvent, MyPropertiesState> {
  final PropertiesRepository _repository;
  final AuthBloc _authBloc;

  MyPropertiesBloc(this._repository, this._authBloc)
    : super(const MyPropertiesState()) {
    on<LoadMyPropertiesEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMyPropertiesEvent event,
    Emitter<MyPropertiesState> emit,
  ) async {
    final token = _authBloc.state.token;
    if (token == null) {
      emit(
        state.copyWith(
          status: MyPropertiesStatus.failure,
          errorMessage: 'Not logged in',
        ),
      );
      return;
    }

    emit(state.copyWith(status: MyPropertiesStatus.loading));
    try {
      final properties = await _repository.fetchMyProperties(token: token);
      emit(
        state.copyWith(
          status: MyPropertiesStatus.success,
          properties: properties,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MyPropertiesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
