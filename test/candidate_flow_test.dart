import 'dart:async';

import 'package:chamby_app/models/candidate.dart';
import 'package:chamby_app/models/connection.dart';
import 'package:chamby_app/models/match.dart';
import 'package:chamby_app/models/vacancy.dart';
import 'package:chamby_app/models/auth_models.dart';
import 'package:chamby_app/providers/auth_provider.dart';
import 'package:chamby_app/providers/candidate_feed_provider.dart';
import 'package:chamby_app/screens/app_shell.dart';
import 'package:chamby_app/screens/candidate/match_screen.dart';
import 'package:chamby_app/screens/candidate/profile_screen.dart';
import 'package:chamby_app/screens/candidate/swipe_feed_screen.dart';
import 'package:chamby_app/services/candidate_service.dart';
import 'package:chamby_app/utils/api_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('CandidateProfileDraft', () {
    test('uses the documented multipart field names and JSON skills', () {
      const draft = CandidateProfileDraft(
        firstName: ' Ana ',
        lastName: ' López ',
        skills: [' Ventas ', '', 'POS'],
        experience: 2,
      );

      expect(draft.toMultipartFields(), containsPair('firstName', 'Ana'));
      expect(draft.toMultipartFields(), containsPair('lastName', 'López'));
      expect(
        draft.toMultipartFields(),
        containsPair('skills', '["Ventas","POS"]'),
      );
      expect(draft.toMultipartFields(), containsPair('experience', '2'));
      expect(draft.toMultipartFields().containsKey('photoUrl'), isFalse);
      expect(parseCandidateExperience('2'), 2);
      expect(parseCandidateExperience('2.5'), isNull);
      expect(parseCandidateExperience('-1'), isNull);
    });
  });

  group('CandidateFeedProvider', () {
    test(
      'keeps the vacancy visible after a failed swipe and emits a safe error',
      () async {
        final gateway = _FakeCandidateGateway(
          feed: [_vacancy],
          swipeError: const ApiError(message: 'Mensaje seguro'),
        );
        final provider = CandidateFeedProvider(gateway);

        await provider.load();
        final result = await provider.decideCurrent(isLike: true);

        expect(result, isNull);
        expect(provider.currentVacancy?.id, _vacancy.id);
        expect(provider.errorMessage, 'Mensaje seguro');
        expect(provider.isSubmitting, isFalse);
      },
    );

    test(
      'prevents duplicate swipe submissions and advances only after success',
      () async {
        final completion = Completer<Match>();
        final gateway = _FakeCandidateGateway(
          feed: [_vacancy],
          swipeCompletion: completion,
        );
        final provider = CandidateFeedProvider(gateway);
        await provider.load();

        final first = provider.decideCurrent(isLike: true);
        final second = provider.decideCurrent(isLike: true);
        expect(gateway.swipeCalls, 1);
        completion.complete(_match(isMatch: false));

        await first;
        await second;
        expect(provider.currentVacancy, isNull);
        expect(provider.state, CandidateFeedState.empty);
      },
    );
  });

  testWidgets(
    'candidate feed shows retry state and does not expose technical errors',
    (tester) async {
      final gateway = _FakeCandidateGateway(
        feedError: const ApiError(
          message: 'La solicitud tardó demasiado. Inténtalo de nuevo.',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: SwipeFeedScreen(gateway: gateway)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('La solicitud tardó demasiado. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );

  testWidgets('candidate profile loads typed profile fields', (tester) async {
    final gateway = _FakeCandidateGateway(profile: _candidate);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CandidateProfileScreen(gateway: gateway)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
  });

  testWidgets('candidate profile saves and shows feedback', (tester) async {
    final gateway = _FakeCandidateGateway(profile: _candidate);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CandidateProfileScreen(gateway: gateway)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Ana María');
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    final saveButton = find.byType(FilledButton).last;
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump();

    expect(gateway.savedDraft?.firstName, 'Ana María');
    expect(find.text('Tu perfil fue actualizado.'), findsOneWidget);
  });

  testWidgets('match navigation renders the real match and empty states', (
    tester,
  ) async {
    final auth = AuthProvider(
      gateway: _CandidateAuthGateway(),
      storage: _FakeSessionStorage(),
      restoreSessionOnStart: false,
    );
    await auth.login(email: 'ana@example.com', password: 'password');
    auth.setMatchedUser(_vacancy);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pump();
    expect(find.text('¡Hicieron match!'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: MatchScreen(onContinue: _noop)));
    await tester.pump();
    expect(find.text('Aún no tienes matches.'), findsOneWidget);
  });
}

const _candidate = Candidate(
  id: 'candidate-1',
  firstName: 'Ana',
  lastName: 'López',
  role: 'Barista',
  skills: ['Ventas'],
);

const _vacancy = Vacancy(
  id: 'vacancy-1',
  title: 'Barista',
  description: 'Atención a clientes',
  name: 'Café Chamby',
);

Match _match({required bool isMatch}) => Match(
  connection: Connection(
    id: 'connection-1',
    candidateId: 'candidate-1',
    vacancyId: 'vacancy-1',
    isMatch: isMatch,
  ),
);

class _FakeCandidateGateway implements CandidateGateway {
  _FakeCandidateGateway({
    this.profile = _candidate,
    this.feed = const [],
    this.feedError,
    this.swipeError,
    this.swipeCompletion,
  });

  final Candidate profile;
  final List<Vacancy> feed;
  final Object? feedError;
  final Object? swipeError;
  final Completer<Match>? swipeCompletion;
  int swipeCalls = 0;
  CandidateProfileDraft? savedDraft;

  @override
  Future<List<Vacancy>> loadFeed() async {
    if (feedError != null) throw feedError!;
    return feed;
  }

  @override
  Future<Candidate> loadProfile() async => profile;

  @override
  Future<Candidate> saveProfile(CandidateProfileDraft draft) async {
    savedDraft = draft;
    return Candidate(
      id: profile.id,
      firstName: draft.firstName.trim(),
      lastName: draft.lastName.trim(),
      role: draft.role,
      skills: draft.skills,
    );
  }

  @override
  Future<Match> swipe({required String vacancyId, required bool isLike}) async {
    swipeCalls += 1;
    if (swipeError != null) throw swipeError!;
    if (swipeCompletion != null) return swipeCompletion!.future;
    return _match(isMatch: false);
  }
}

void _noop() {}

class _CandidateAuthGateway implements AuthGateway {
  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async => const AuthResponse(
    message: 'ok',
    token: 'candidate-token',
    user: AuthUser(
      id: 'user-1',
      email: 'ana@example.com',
      role: AccountRole.candidate,
    ),
  );

  @override
  Future<AuthResponse> register({required Map<String, dynamic> data}) =>
      login(email: '', password: '');
}

class _FakeSessionStorage implements AuthSessionStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> save(AuthSession session) async {}
}
