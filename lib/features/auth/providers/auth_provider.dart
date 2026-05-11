import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? errorMessage;
  final String? infoMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.userId,
    this.email,
    this.displayName,
    this.errorMessage,
    this.infoMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends ChangeNotifier {
  final _client = sb.Supabase.instance.client;
  StreamSubscription<sb.AuthState>? _authSub;

  AuthState _state = const AuthState(status: AuthStatus.loading);
  AuthState get state => _state;

  void _setState(AuthState s) {
    _state = s;
    notifyListeners();
  }

  AuthNotifier() {
    _init();
  }

  void _init() {
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case sb.AuthChangeEvent.initialSession:
        case sb.AuthChangeEvent.signedIn:
        case sb.AuthChangeEvent.tokenRefreshed:
        case sb.AuthChangeEvent.userUpdated:
          if (session != null) {
            _setState(AuthState(
              status: AuthStatus.authenticated,
              userId: session.user.id,
              email: session.user.email,
              displayName: session.user.userMetadata?['full_name'] as String?,
            ));
          } else {
            _setState(const AuthState(status: AuthStatus.unauthenticated));
          }
        case sb.AuthChangeEvent.signedOut:
          _setState(const AuthState(status: AuthStatus.unauthenticated));
        default:
          break;
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setState(const AuthState(status: AuthStatus.loading));
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.session != null) return true;

      _setState(const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed. Please try again.',
      ));
      return false;
    } on sb.AuthException catch (e) {
      _setState(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: _friendlyError(e.message),
      ));
      return false;
    } catch (_) {
      _setState(const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Network error — check your connection.',
      ));
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password, {
    String? fullName,
  }) async {
    _setState(const AuthState(status: AuthStatus.loading));
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName ?? ''},
      );

      if (res.session != null) {
        // Email confirmation disabled — user is immediately signed in.
        return true;
      }

      // Email confirmation enabled — session is null until link is clicked.
      _setState(const AuthState(
        status: AuthStatus.unauthenticated,
        infoMessage:
            'Account created! Check your email and click the confirmation link before signing in.',
      ));
      return true;
    } on sb.AuthException catch (e) {
      _setState(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: _friendlyError(e.message),
      ));
      return false;
    } catch (_) {
      _setState(const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Network error — check your connection.',
      ));
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login')) return 'Incorrect email or password.';
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (lower.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    return raw;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>(
  (ref) => AuthNotifier(),
);

final authStateProvider = Provider<AuthState>(
  (ref) => ref.watch(authNotifierProvider).state,
);
