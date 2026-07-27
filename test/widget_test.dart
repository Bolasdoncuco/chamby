import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chamby_app/main.dart';
import 'package:chamby_app/providers/auth_provider.dart';
import 'package:chamby_app/providers/job_creation_provider.dart';

void main() {
  testWidgets('Chamby inicia en la pantalla de bienvenida sin API viva', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => JobCreationProvider()),
        ],
        child: const ChambyApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
