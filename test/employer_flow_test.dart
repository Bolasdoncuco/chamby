import 'dart:async';

import 'package:chamby_app/models/vacancy.dart';
import 'package:chamby_app/providers/employer_provider.dart';
import 'package:chamby_app/screens/employer/dashboard_screen.dart';
import 'package:chamby_app/screens/employer/vacancy_candidates_screen.dart';
import 'package:chamby_app/services/employer_service.dart';
import 'package:chamby_app/utils/api_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmployerVacancyFormProvider', () {
    test('validates required fields and salary before making a request', () async {
      final gateway = _FakeEmployerGateway();
      final provider = EmployerVacancyFormProvider(gateway);

      final result = await provider.submit(
        const VacancyDraft(title: '', description: '', salary: 'sin número'),
      );

      expect(result, isFalse);
      expect(provider.validationErrors['title'], 'El título de la vacante es obligatorio.');
      expect(provider.validationErrors['description'], 'La descripción de la vacante es obligatoria.');
      expect(provider.validationErrors['salary'], 'El sueldo debe ser un número mayor a cero.');
      expect(gateway.createCalls, 0);
    });

    test('prevents duplicate vacancy submissions while the first request is active', () async {
      final completion = Completer<Vacancy>();
      final gateway = _FakeEmployerGateway(createCompletion: completion);
      final provider = EmployerVacancyFormProvider(gateway);
      const draft = VacancyDraft(title: 'Barista', description: 'Atención a clientes', salary: '9000');

      final first = provider.submit(draft);
      final second = provider.submit(draft);
      expect(gateway.createCalls, 1);
      completion.complete(_vacancy);

      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(provider.isSubmitting, isFalse);
    });
  });

  group('EmployerVacanciesProvider', () {
    test('exposes a safe retry state after a loading error', () async {
      final provider = EmployerVacanciesProvider(
        _FakeEmployerGateway(vacanciesError: const ApiError(message: 'La solicitud tardó demasiado. Inténtalo de nuevo.')),
      );

      await provider.load();

      expect(provider.state, EmployerListState.error);
      expect(provider.errorMessage, 'La solicitud tardó demasiado. Inténtalo de nuevo.');
    });
  });

  testWidgets('dashboard renders retry UI without raw server details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmployerDashboardScreen(
          gateway: _FakeEmployerGateway(
            vacanciesError: const ApiError(message: 'No fue posible completar la solicitud. Inténtalo más tarde.'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.textContaining('stack trace'), findsNothing);
  });

  testWidgets('vacancy candidates renders an empty group and accessible tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VacancyCandidatesScreen(
          vacancy: _vacancy,
          gateway: _FakeEmployerGateway(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay candidatos en esta sección.'), findsOneWidget);
    expect(find.bySemanticsLabel('Ver seleccionados'), findsOneWidget);
    expect(find.bySemanticsLabel('Ver interesados'), findsOneWidget);
  });

  testWidgets('vacancy candidates preserves timeout feedback and invokes AppShell back callback', (tester) async {
    var backedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: VacancyCandidatesScreen(
          vacancy: _vacancy,
          gateway: _FakeEmployerGateway(
            candidatesError: const ApiError(message: 'La solicitud tardó demasiado. Inténtalo de nuevo.'),
          ),
          onBack: () => backedOut = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('La solicitud tardó demasiado. Inténtalo de nuevo.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    await tester.tap(find.byTooltip('Regresar al dashboard'));
    expect(backedOut, isTrue);
  });
}

const _vacancy = Vacancy(
  id: 'vacancy-1',
  title: 'Barista',
  description: 'Atención a clientes',
  salaryMin: 9000,
  isActive: true,
);

class _FakeEmployerGateway implements EmployerGateway {
  _FakeEmployerGateway({this.vacanciesError, this.candidatesError, this.createCompletion});

  final Object? vacanciesError;
  final Object? candidatesError;
  final Completer<Vacancy>? createCompletion;
  int createCalls = 0;

  @override
  Future<Vacancy> createVacancy(VacancyDraft draft) async {
    createCalls += 1;
    return createCompletion?.future ?? _vacancy;
  }

  @override
  Future<VacancyCandidates> loadCandidates(String vacancyId) async {
    if (candidatesError != null) throw candidatesError!;
    return const VacancyCandidates();
  }

  @override
  Future<List<Vacancy>> loadVacancies() async {
    if (vacanciesError != null) throw vacanciesError!;
    return const [];
  }

  @override
  Future<Vacancy> updateVacancy({required String vacancyId, required VacancyDraft draft}) async => _vacancy;
}
