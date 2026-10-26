import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStateType { unauthenticated, authenticated }

class AuthState {
  final AuthStateType type;
  final int? userId;
  final String? username;
  final String? fullName;
  final String? role;

  const AuthState._({
    required this.type,
    this.userId,
    this.username,
    this.fullName,
    this.role,
  });

  const AuthState.unauthenticated()
      : type = AuthStateType.unauthenticated,
        userId = null,
        username = null,
        fullName = null,
        role = null;

  AuthState.authenticated({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
  }) : type = AuthStateType.authenticated;

  bool get isAuthenticated => type == AuthStateType.authenticated;
  bool get isOwner => role == 'OWNER' || role == 'owner';
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.unauthenticated();
  }

  void setAuthenticated({
    required int userId,
    required String username,
    required String fullName,
    required String role,
  }) {
    state = AuthState.authenticated(
      userId: userId,
      username: username,
      fullName: fullName,
      role: role,
    );
  }

  Future<void> logout() async {
    state = const AuthState.unauthenticated();
  }
}