import 'package:equatable/equatable.dart';
import '../core/auth_storage.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final AuthSession session;
  const LoggedIn(this.session);
}

class LoggedOut extends AuthEvent {}
