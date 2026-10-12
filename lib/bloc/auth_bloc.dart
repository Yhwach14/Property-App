import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/auth_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthStorage _storage;

  AuthBloc(this._storage) : super(const AuthState.unknown()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final session = await _storage.load();
    if (session == null) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(session.token, session.user));
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    await _storage.save(event.session);
    emit(AuthState.authenticated(event.session.token, event.session.user));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _storage.clear();
    emit(const AuthState.unauthenticated());
  }
}
