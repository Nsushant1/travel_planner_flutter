import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.userId,
    this.email,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ChangeNotifier so GoRouter can use it as refreshListenable
class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState(status: AuthStatus.loading);

  AuthState get state => _state;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  AuthNotifier() {
    _initialize();
  }

  void _initialize() {
    // Simulate checking for an existing session (will use Supabase in Phase 2)
    Future.delayed(const Duration(milliseconds: 800), () {
      _setState(const AuthState(status: AuthStatus.unauthenticated));
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setState(_state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      // TODO Phase 2: replace with Supabase signIn
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || password.length < 6) {
        throw Exception('Invalid credentials');
      }

      _setState(AuthState(
        status: AuthStatus.authenticated,
        userId: 'local_user',
        email: email,
      ));
      return true;
    } catch (e) {
      _setState(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setState(_state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      // TODO Phase 2: replace with Supabase signUp
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      _setState(AuthState(
        status: AuthStatus.authenticated,
        userId: 'local_user',
        email: email,
      ));
      return true;
    } catch (e) {
      _setState(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<void> signOut() async {
    // TODO Phase 2: call Supabase signOut
    _setState(const AuthState(status: AuthStatus.unauthenticated));
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>(
  (ref) => AuthNotifier(),
);

// Convenience provider for just reading auth state
final authStateProvider = Provider<AuthState>(
  (ref) => ref.watch(authNotifierProvider).state,
);
