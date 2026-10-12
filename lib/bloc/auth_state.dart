import 'package:equatable/equatable.dart';
import '../models/auth_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? token;
  final AuthUser? user;

  const AuthState({this.status = AuthStatus.unknown, this.token, this.user});

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.authenticated(String token, AuthUser user)
    : this(status: AuthStatus.authenticated, token: token, user: user);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, token, user];
}
