import 'candidate.dart';
import 'connection.dart';
import 'json_parsing.dart';
import 'vacancy.dart';

class Match {
  const Match({required this.connection, this.candidate, this.vacancy});

  final Connection connection;
  final CandidateSummary? candidate;
  final VacancySummary? vacancy;

  bool get isMatch => connection.isMatch;

  factory Match.fromJson(JsonObject json) {
    final candidate = mapValue(json['candidate']);
    final vacancy = mapValue(json['vacancy']);
    return Match(
      connection: Connection.fromJson(json),
      candidate: candidate == null
          ? null
          : CandidateSummary.fromJson(candidate),
      vacancy: vacancy == null ? null : VacancySummary.fromJson(vacancy),
    );
  }
}
