import 'package:flutter/foundation.dart';

import '../models/match.dart';
import '../models/vacancy.dart';
import '../services/candidate_service.dart';

enum CandidateFeedState { loading, ready, empty, error }

class CandidateFeedProvider with ChangeNotifier {
  CandidateFeedProvider(this._gateway);

  final CandidateGateway _gateway;
  CandidateFeedState _state = CandidateFeedState.loading;
  List<Vacancy> _vacancies = const [];
  String? _errorMessage;
  bool _isSubmitting = false;

  CandidateFeedState get state => _state;
  List<Vacancy> get vacancies => List.unmodifiable(_vacancies);
  Vacancy? get currentVacancy => _vacancies.isEmpty ? null : _vacancies.first;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  Future<void> load() async {
    _state = CandidateFeedState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _vacancies = await _gateway.loadFeed();
      _state = _vacancies.isEmpty
          ? CandidateFeedState.empty
          : CandidateFeedState.ready;
    } catch (error) {
      _state = CandidateFeedState.error;
      _errorMessage = candidateErrorMessage(error);
    }
    notifyListeners();
  }

  Future<Match?> decideCurrent({required bool isLike}) async {
    final vacancy = currentVacancy;
    if (vacancy == null || _isSubmitting) return null;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final match = await _gateway.swipe(vacancyId: vacancy.id, isLike: isLike);
      _vacancies = _vacancies.skip(1).toList(growable: false);
      _state = _vacancies.isEmpty
          ? CandidateFeedState.empty
          : CandidateFeedState.ready;
      return match;
    } catch (error) {
      _errorMessage = candidateErrorMessage(error);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
