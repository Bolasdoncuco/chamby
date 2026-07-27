import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';
import '../services/api_service.dart';
import '../utils/api_error.dart';

enum AppState { loading, welcome, login, signup, app }
enum UserRole { employer, candidate, none }
enum CurrentView { feed, create, match, profile, dashboard, candidates, settings, editVacancy }

class AuthSession {
  const AuthSession({required this.token, required this.role});

  final String token;
  final AccountRole role;

  bool get isValid => token.isNotEmpty && (role == AccountRole.candidate || role == AccountRole.employer);
}

abstract interface class AuthSessionStorage {
  Future<AuthSession?> read();
  Future<void> save(AuthSession session);
  Future<void> clear();
}

class SharedPreferencesAuthSessionStorage implements AuthSessionStorage {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    Object? failure;
    try {
      await preferences.remove(_tokenKey);
    } catch (error) {
      failure ??= error;
    }
    try {
      await preferences.remove(_roleKey);
    } catch (error) {
      failure ??= error;
    }
    if (failure != null) throw failure;
  }

  @override
  Future<AuthSession?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    final role = AccountRole.fromJson(preferences.getString(_roleKey));
    if (token == null || token.isEmpty) return null;
    return AuthSession(token: token, role: role);
  }

  @override
  Future<void> save(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, session.token);
    await preferences.setString(_roleKey, session.role.value);
  }
}

abstract interface class AuthGateway {
  Future<AuthResponse> login({required String email, required String password});
  Future<AuthResponse> register({required Map<String, dynamic> data});
}

class ApiClientAuthGateway implements AuthGateway {
  ApiClientAuthGateway(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponse> login({required String email, required String password}) => _post(
        '/auth/login',
        {'email': email, 'password': password},
        expectedStatus: 200,
      );

  @override
  Future<AuthResponse> register({required Map<String, dynamic> data}) => _post(
        '/auth/register',
        data,
        expectedStatus: 201,
      );

  Future<AuthResponse> _post(String path, Object data, {required int expectedStatus}) async {
    final response = await _client.post<dynamic>(path, data);
    if (response.statusCode != expectedStatus || response.data is! Map) {
      throw const ApiError(message: 'No fue posible completar la solicitud. Inténtalo más tarde.');
    }
    return AuthResponse.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}

class AuthProvider with ChangeNotifier {
  AuthProvider({
    AuthGateway? gateway,
    AuthSessionStorage? storage,
    bool restoreSessionOnStart = true,
  })  : _gateway = gateway ?? ApiClientAuthGateway(ApiService.client),
        _storage = storage ?? SharedPreferencesAuthSessionStorage() {
    if (restoreSessionOnStart) {
      _initialization = checkAuthStatus();
    } else {
      _appState = AppState.welcome;
      _initialization = Future<void>.value();
    }
  }

  final AuthGateway _gateway;
  final AuthSessionStorage _storage;

  late final Future<void> _initialization;
  AppState _appState = AppState.loading;
  UserRole _userRole = UserRole.none;
  CurrentView _currentView = CurrentView.feed;
  AuthSession? _session;
  Object? _matchedUser;
  Object? _selectedVacancy;
  bool _isLoading = false;
  String? _errorMessage;

  AppState get appState => _appState;
  UserRole get userRole => _userRole;
  CurrentView get currentView => _currentView;
  AuthSession? get session => _session;
  dynamic get matchedUser => _matchedUser;
  dynamic get selectedVacancy => _selectedVacancy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<void> get initialization => _initialization;

  void setAppState(AppState state) {
    _appState = state;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) => _authenticate(
        () => _gateway.login(email: email, password: password),
      );

  Future<bool> register({required Map<String, dynamic> data}) => _authenticate(
        () => _gateway.register(data: data),
      );

  Future<bool> _authenticate(Future<AuthResponse> Function() request) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await request();
      final nextSession = AuthSession(token: response.token, role: response.user.role);
      if (!nextSession.isValid) {
        throw const FormatException('Rol de sesión inválido.');
      }
      await _storage.save(nextSession);
      _applySession(nextSession);
      return true;
    } catch (error) {
      _errorMessage = _messageFor(error);
      if (_session == null) _appState = AppState.welcome;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final storedSession = await _storage.read();
      if (storedSession == null) {
        _appState = AppState.welcome;
      } else if (storedSession.isValid) {
        _applySession(storedSession);
      } else {
        await _storage.clear();
        _clearInMemorySession();
      }
    } catch (_) {
      _clearInMemorySession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLogout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    var shouldClearMemory = true;
    try {
      await _storage.clear();
    } catch (_) {
      try {
        final remainingSession = await _storage.read();
        shouldClearMemory = remainingSession?.isValid != true;
      } catch (_) {
        shouldClearMemory = true;
      }
      _errorMessage = 'No fue posible borrar la sesión local. Inténtalo nuevamente.';
    } finally {
      if (shouldClearMemory) _clearInMemorySession();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool canAccess(CurrentView view) {
    switch (_userRole) {
      case UserRole.candidate:
        return switch (view) {
          CurrentView.feed || CurrentView.match || CurrentView.profile || CurrentView.settings => true,
          _ => false,
        };
      case UserRole.employer:
        return switch (view) {
          CurrentView.feed ||
          CurrentView.create ||
          CurrentView.dashboard ||
          CurrentView.candidates ||
          CurrentView.settings ||
          CurrentView.editVacancy => true,
          _ => false,
        };
      case UserRole.none:
        return false;
    }
  }

  void setCurrentView(CurrentView view) {
    if (!canAccess(view)) return;
    _currentView = view;
    notifyListeners();
  }

  void setMatchedUser(Object user) {
    if (!canAccess(CurrentView.match)) return;
    _matchedUser = user;
    _currentView = CurrentView.match;
    notifyListeners();
  }

  void setSelectedVacancy(Object vacancy, CurrentView view) {
    if (!canAccess(view) || (view != CurrentView.candidates && view != CurrentView.editVacancy)) return;
    _selectedVacancy = vacancy;
    _currentView = view;
    notifyListeners();
  }

  void _applySession(AuthSession session) {
    _session = session;
    _userRole = _userRoleFor(session.role);
    _appState = AppState.app;
    _currentView = _userRole == UserRole.employer ? CurrentView.dashboard : CurrentView.feed;
    _matchedUser = null;
    _selectedVacancy = null;
  }

  void _clearInMemorySession() {
    _session = null;
    _userRole = UserRole.none;
    _currentView = CurrentView.feed;
    _matchedUser = null;
    _selectedVacancy = null;
    _appState = AppState.welcome;
  }

  static UserRole _userRoleFor(AccountRole role) => switch (role) {
        AccountRole.candidate => UserRole.candidate,
        AccountRole.employer => UserRole.employer,
        AccountRole.unknown => UserRole.none,
      };

  static String _messageFor(Object error) {
    if (error is ApiError) return error.message;
    if (error is FormatException) return 'La respuesta del servidor no es válida. Inténtalo de nuevo.';
    return 'No fue posible completar la solicitud. Inténtalo más tarde.';
  }
}
