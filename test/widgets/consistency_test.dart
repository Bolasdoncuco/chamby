import 'package:chamby_app/widgets/common/app_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('error state exposes a live message and retry action', (tester) async {
    var retries = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppStateView.error(
          message: 'No fue posible cargar los datos.',
          onRetry: () => retries++,
        ),
      ),
    ));

    expect(find.text('No fue posible cargar los datos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(retries, 1);
  });

  testWidgets('loading state is announced accessibly', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppStateView.loading()),
    ));

    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
  });
}
