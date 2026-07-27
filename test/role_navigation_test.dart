import 'package:chamby_app/models/auth_models.dart';
import 'package:chamby_app/providers/auth_provider.dart';
import 'package:chamby_app/screens/app_shell.dart';
import 'package:chamby_app/screens/common/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('candidate navigation exposes role-safe labels', (tester) async {
    final auth = await _auth(AccountRole.candidate);
    auth.setCurrentView(CurrentView.settings);
    await tester.pumpWidget(_app(auth, const SizedBox.shrink()));

    expect(find.byTooltip('Ver vacantes'), findsOneWidget);
    expect(find.byTooltip('Ver mi perfil'), findsOneWidget);
    expect(find.byTooltip('Abrir configuración'), findsOneWidget);
    expect(find.byTooltip('Ver dashboard'), findsNothing);
  });

  testWidgets('employer navigation exposes dashboard and candidate labels', (tester) async {
    final auth = await _auth(AccountRole.employer);
    auth.setCurrentView(CurrentView.feed);
    await tester.pumpWidget(_app(auth, const SizedBox.shrink()));

    expect(find.byTooltip('Ver dashboard'), findsOneWidget);
    expect(find.byTooltip('Ver candidatos'), findsOneWidget);
    expect(find.byTooltip('Abrir configuración'), findsOneWidget);
    expect(find.byTooltip('Ver mi perfil'), findsNothing);
  });

  testWidgets('settings requires logout confirmation', (tester) async {
    final auth = await _auth(AccountRole.candidate);
    auth.setCurrentView(CurrentView.settings);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: const MaterialApp(home: SettingsScreen(loadProfile: false)),
    ));

    await tester.ensureVisible(find.text('Cerrar Sesión'));
    await tester.tap(find.text('Cerrar Sesión'));
    await tester.pump();

    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });
}

Widget _app(AuthProvider auth, [Widget? content]) => ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(home: AppShell(contentOverride: content)),
    );

Future<AuthProvider> _auth(AccountRole role) async {
  final auth = AuthProvider(
    gateway: _Gateway(role),
    storage: _Storage(),
    restoreSessionOnStart: false,
  );
  await auth.login(email: 'test@example.com', password: 'password');
  return auth;
}

class _Gateway implements AuthGateway {
  _Gateway(this.role);
  final AccountRole role;

  @override
  Future<AuthResponse> login({required String email, required String password}) async => AuthResponse(
        message: 'ok',
        token: 'token',
        user: AuthUser(id: 'user', email: email, role: role),
      );

  @override
  Future<AuthResponse> register({required Map<String, dynamic> data}) => login(email: '', password: '');
}

class _Storage implements AuthSessionStorage {
  AuthSession? session;

  @override
  Future<void> clear() async => session = null;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> save(AuthSession value) async => session = value;
}
