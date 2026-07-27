import 'dart:async';

import 'package:chamby_app/models/auth_models.dart';
import 'package:chamby_app/providers/auth_provider.dart';
import 'package:chamby_app/utils/api_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chamby_app/screens/auth/login_screen.dart';
import 'package:chamby_app/screens/auth/signup_screen.dart';
import 'package:chamby_app/screens/app_shell.dart';
import 'package:chamby_app/screens/candidate/swipe_feed_screen.dart';

void main() {
  group('AuthProvider', () {
    test('restores only a valid persisted session', () async {
      final storage = FakeSessionStorage(
        const AuthSession(token: 'saved-token', role: AccountRole.candidate),
      );
      final provider = AuthProvider(storage: storage, gateway: FakeAuthGateway());

      await provider.initialization;

      expect(provider.appState, AppState.app);
      expect(provider.userRole, UserRole.candidate);
      expect(provider.currentView, CurrentView.feed);
      expect(provider.session?.token, 'saved-token');
      expect(provider.isLoading, isFalse);
    });

    test('clears an invalid persisted role instead of opening the app', () async {
      final storage = FakeSessionStorage(
        const AuthSession(token: 'saved-token', role: AccountRole.unknown),
      );
      final provider = AuthProvider(storage: storage, gateway: FakeAuthGateway());

      await provider.initialization;

      expect(provider.appState, AppState.welcome);
      expect(provider.session, isNull);
      expect(storage.wasCleared, isTrue);
    });

    test('blocks duplicate login while the first request is loading', () async {
      final response = Completer<AuthResponse>();
      final gateway = FakeAuthGateway(loginResponse: response.future);
      final provider = AuthProvider(
        storage: FakeSessionStorage(null),
        gateway: gateway,
        restoreSessionOnStart: false,
      );

      final firstLogin = provider.login(email: 'ana@example.com', password: 'secreto');

      expect(provider.isLoading, isTrue);
      expect(await provider.login(email: 'ana@example.com', password: 'secreto'), isFalse);
      expect(gateway.loginCalls, 1);

      response.complete(_authResponse(AccountRole.employer));
      expect(await firstLogin, isTrue);
      expect(provider.userRole, UserRole.employer);
      expect(provider.currentView, CurrentView.dashboard);
    });

    test('exposes a normalized Spanish API error', () async {
      final provider = AuthProvider(
        storage: FakeSessionStorage(null),
        gateway: FakeAuthGateway(loginError: const ApiError(message: 'La solicitud tardó demasiado. Inténtalo de nuevo.')),
        restoreSessionOnStart: false,
      );

      expect(await provider.login(email: 'ana@example.com', password: 'secreto'), isFalse);

      expect(provider.errorMessage, 'La solicitud tardó demasiado. Inténtalo de nuevo.');
      expect(provider.appState, AppState.welcome);
      expect(provider.isLoading, isFalse);
    });

    test('logout clears persisted credentials and dependent navigation state', () async {
      final storage = FakeSessionStorage(null);
      final provider = AuthProvider(
        storage: storage,
        gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.employer))),
        restoreSessionOnStart: false,
      );
      await provider.login(email: 'empresa@example.com', password: 'secreto');
      provider.setSelectedVacancy({'id': 'vacancy-1'}, CurrentView.candidates);

      await provider.handleLogout();

      expect(storage.wasCleared, isTrue);
      expect(provider.session, isNull);
      expect(provider.userRole, UserRole.none);
      expect(provider.currentView, CurrentView.feed);
      expect(provider.selectedVacancy, isNull);
      expect(provider.matchedUser, isNull);
      expect(provider.appState, AppState.welcome);
    });

    test('rejects cross-role navigation through provider state', () async {
      final candidate = AuthProvider(
        storage: FakeSessionStorage(null),
        gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.candidate))),
        restoreSessionOnStart: false,
      );
      await candidate.login(email: 'ana@example.com', password: 'secreto');
      candidate.setCurrentView(CurrentView.dashboard);

      expect(candidate.currentView, CurrentView.feed);

      final employer = AuthProvider(
        storage: FakeSessionStorage(null),
        gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.employer))),
        restoreSessionOnStart: false,
      );
      await employer.login(email: 'empresa@example.com', password: 'secreto');
      employer.setCurrentView(CurrentView.profile);

      expect(employer.currentView, CurrentView.dashboard);
    });

    test('logout keeps the authenticated session when persisted cleanup fails', () async {
      final storage = FakeSessionStorage(null);
      final provider = AuthProvider(
        storage: storage,
        gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.candidate))),
        restoreSessionOnStart: false,
      );
      await provider.login(email: 'ana@example.com', password: 'secreto');
      storage.clearError = StateError('storage unavailable');

      await provider.handleLogout();

      expect(provider.appState, AppState.welcome);
      expect(provider.session, isNull);
      expect(provider.userRole, UserRole.none);
      expect(provider.errorMessage, 'No fue posible borrar la sesión local. Inténtalo nuevamente.');
      expect(provider.isLoading, isFalse);
    });

    test('clears memory when role-key removal fails after token removal', () async {
      final storage = FakeSessionStorage(null)..failRoleRemoval = true;
      final provider = AuthProvider(
        storage: storage,
        gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.candidate))),
        restoreSessionOnStart: false,
      );
      await provider.login(email: 'ana@example.com', password: 'secreto');

      await provider.handleLogout();
      final restored = AuthProvider(storage: storage, gateway: FakeAuthGateway());
      await restored.initialization;

      expect(storage.tokenRemovalAttempted, isTrue);
      expect(storage.roleRemovalAttempted, isTrue);
      expect(provider.appState, AppState.welcome);
      expect(provider.session, isNull);
      expect(provider.userRole, UserRole.none);
      expect(provider.errorMessage, isNotNull);
      expect(restored.appState, AppState.welcome);
      expect(restored.session, isNull);
    });

    test('clears memory when token-key removal fails after role removal', () async {
      final storage = FakeSessionStorage(null)..failTokenRemoval = true;
      final provider = AuthProvider(
        storage: storage,
        gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.candidate))),
        restoreSessionOnStart: false,
      );
      await provider.login(email: 'ana@example.com', password: 'secreto');

      await provider.handleLogout();
      final restored = AuthProvider(storage: storage, gateway: FakeAuthGateway());
      await restored.initialization;

      expect(storage.tokenRemovalAttempted, isTrue);
      expect(storage.roleRemovalAttempted, isTrue);
      expect(provider.appState, AppState.welcome);
      expect(provider.session, isNull);
      expect(provider.errorMessage, isNotNull);
      expect(restored.appState, AppState.welcome);
      expect(restored.session, isNull);
    });
  });

  testWidgets('login shows Spanish validation and uses provider loading state', (tester) async {
    final response = Completer<AuthResponse>();
    final provider = AuthProvider(
      storage: FakeSessionStorage(null),
      gateway: FakeAuthGateway(loginResponse: response.future),
      restoreSessionOnStart: false,
    );
    await tester.pumpWidget(_app(provider, const LoginScreen()));

    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();
    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);

    await tester.enterText(_fieldWithHint('Correo electrónico'), 'ana@example.com');
    await tester.enterText(_fieldWithHint('Contraseña'), 'secreto');
    await tester.tap(find.text('Iniciar Sesión'));
    await tester.pump();

    expect(provider.isLoading, isTrue);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

    response.complete(_authResponse(AccountRole.candidate));
    await tester.pumpAndSettle();
    expect(provider.appState, AppState.app);
  });

  testWidgets('signup validates email and sends only candidate contract fields', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gateway = FakeAuthGateway(registerResponse: Future.value(_authResponse(AccountRole.candidate)));
    final provider = AuthProvider(storage: FakeSessionStorage(null), gateway: gateway, restoreSessionOnStart: false);
    await tester.pumpWidget(_app(provider, const SignupScreen()));

    await tester.tap(find.text('Soy Candidato'));
    await tester.pumpAndSettle();
    await tester.enterText(_fieldWithHint('Nombre(s)'), 'Ana');
    await tester.enterText(_fieldWithHint('Apellido(s)'), 'López');
    await tester.enterText(_fieldWithHint('Email'), 'nombre@');
    await tester.enterText(_fieldWithHint('Contraseña'), 'secreto');
    await tester.tap(find.text('Finalizar Registro'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);
    expect(gateway.registeredData, isNull);

    await tester.enterText(_fieldWithHint('Email'), 'ana@example.com');
    await tester.tap(find.text('Finalizar Registro'));
    await tester.pumpAndSettle();

    expect(find.text('Tu Match Card'), findsNothing);
    expect(find.text('HABILIDADES'), findsNothing);
    expect(find.text('WhatsApp'), findsNothing);

    expect(gateway.registeredData, {
      'email': 'ana@example.com',
      'password': 'secreto',
      'role': 'CANDIDATE',
      'firstName': 'Ana',
      'lastName': 'López',
    });
  });

  testWidgets('signup sends only employer contract fields', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gateway = FakeAuthGateway(registerResponse: Future.value(_authResponse(AccountRole.employer)));
    final provider = AuthProvider(storage: FakeSessionStorage(null), gateway: gateway, restoreSessionOnStart: false);
    await tester.pumpWidget(_app(provider, const SignupScreen()));

    await tester.tap(find.text('Soy Empresa'));
    await tester.pumpAndSettle();
    await tester.enterText(_fieldWithHint('Nombre de la empresa'), 'Café Chamby');
    await tester.enterText(_fieldWithHint('Email corporativo'), 'empresa@example.com');
    await tester.enterText(_fieldWithHint('Contraseña'), 'secreto');
    await tester.tap(find.text('Finalizar Registro'));
    await tester.pumpAndSettle();

    expect(gateway.registeredData, {
      'email': 'empresa@example.com',
      'password': 'secreto',
      'role': 'EMPLOYER',
      'companyName': 'Café Chamby',
    });
  });

  testWidgets('employer feed never renders the candidate swipe screen without a vacancy', (tester) async {
    final provider = AuthProvider(
      storage: FakeSessionStorage(null),
      gateway: FakeAuthGateway(loginResponse: Future.value(_authResponse(AccountRole.employer))),
      restoreSessionOnStart: false,
    );
    await provider.login(email: 'empresa@example.com', password: 'secreto');
    provider.setCurrentView(CurrentView.feed);

    await tester.pumpWidget(_app(provider, const AppShell()));

    expect(find.byType(SwipeFeedScreen), findsNothing);
    expect(find.text('Selecciona una vacante para revisar candidatos.'), findsOneWidget);
  });

}

Widget _app(AuthProvider provider, Widget home) => ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: home),
    );

Finder _fieldWithHint(String hintText) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hintText,
      description: 'TextField with hint $hintText',
    );

AuthResponse _authResponse(AccountRole role) => AuthResponse(
      message: 'ok',
      token: 'token-${role.value}',
      user: AuthUser(id: 'user-1', email: 'user@example.com', role: role),
    );

class FakeSessionStorage implements AuthSessionStorage {
  FakeSessionStorage(this.session)
      : _tokenExists = session != null,
        _roleExists = session != null;

  AuthSession? session;
  bool wasCleared = false;
  Object? clearError;
  bool failRoleRemoval = false;
  bool failTokenRemoval = false;
  bool tokenRemovalAttempted = false;
  bool roleRemovalAttempted = false;
  bool _tokenExists = false;
  bool _roleExists;

  @override
  Future<void> clear() async {
    tokenRemovalAttempted = true;
    if (!failTokenRemoval) _tokenExists = false;
    roleRemovalAttempted = true;
    if (!failRoleRemoval) _roleExists = false;
    if (clearError != null) throw clearError!;
    if (failTokenRemoval) throw StateError('auth_token removal failed');
    if (failRoleRemoval) throw StateError('user_role removal failed');
    wasCleared = true;
  }

  @override
  Future<AuthSession?> read() async => _tokenExists && _roleExists ? session : null;

  @override
  Future<void> save(AuthSession value) async {
    session = value;
    _tokenExists = true;
    _roleExists = true;
  }
}

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({
    Future<AuthResponse>? loginResponse,
    Future<AuthResponse>? registerResponse,
    this.loginError,
  })  : _loginResponse = loginResponse,
        _registerResponse = registerResponse;

  final Future<AuthResponse>? _loginResponse;
  final Future<AuthResponse>? _registerResponse;
  final Object? loginError;
  int loginCalls = 0;
  Map<String, dynamic>? registeredData;

  @override
  Future<AuthResponse> login({required String email, required String password}) {
    loginCalls++;
    if (loginError != null) return Future<AuthResponse>.error(loginError!);
    return _loginResponse ?? Future.value(_authResponse(AccountRole.candidate));
  }

  @override
  Future<AuthResponse> register({required Map<String, dynamic> data}) {
    registeredData = Map<String, dynamic>.from(data);
    return _registerResponse ?? Future.value(_authResponse(AccountRole.candidate));
  }
}
