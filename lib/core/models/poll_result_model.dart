import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk hasil agregasi polling (real-time)
class PollResult {
  final String pollId;
  final int totalVotes;
  final int totalParticipants;
  final double participationRate;
  final DateTime lastUpdated;

  final List<OptionResult> options;
  final OptionResult? winner;

  // Demographics
  final PollDemographics? demographics;

  PollResult({
    required this.pollId,
    required this.totalVotes,
    required this.totalParticipants,
    required this.participationRate,
    required this.lastUpdated,
    required this.options,
    this.winner,
    this.demographics,
  });

  // Factory from Firestore
  factory PollResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PollResult.fromMap(data, doc.id);
  }

  factory PollResult.fromMap(Map<String, dynamic> map, String pollId) {
    final optionsList = (map['options'] as List<dynamic>?)
            ?.map((e) => OptionResult.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PollResult(
      pollId: pollId,
      totalVotes: map['totalVotes'] ?? 0,
      totalParticipants: map['totalParticipants'] ?? 0,
      participationRate: (map['participationRate'] ?? 0).toDouble(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      options: optionsList,
      winner: map['winner'] != null
          ? OptionResult.fromMap(map['winner'] as Map<String, dynamic>)
          : null,
      demographics: map['demographics'] != null
          ? PollDemographics.fromMap(map['demographics'] as Map<String, dynamic>)
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'totalVotes': totalVotes,
      'totalParticipants': totalParticipants,
      'participationRate': participationRate,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'options': options.map((e) => e.toMap()).toList(),
      'winner': winner?.toMap(),
      'demographics': demographics?.toMap(),
    };
  }

  // Helper methods
  OptionResult? getOptionResult(String optionId) {
    try {
      return options.firstWhere((opt) => opt.optionId == optionId);
    } catch (e) {
      return null;
    }
  }

  List<OptionResult> get sortedByVotes {
    final sorted = List<OptionResult>.from(options);
    sorted.sort((a, b) => b.voteCount.compareTo(a.voteCount));
    return sorted;
  }
}

/// Model untuk hasil per opsi
class OptionResult {
  final String optionId;
  final String text;
  final int voteCount;
  final double percentage;

  OptionResult({
    required this.optionId,
    required this.text,
    required this.voteCount,
    required this.percentage,
  });

  factory OptionResult.fromMap(Map<String, dynamic> map) {
    return OptionResult(
      optionId: map['optionId'] ?? '',
      text: map['text'] ?? '',
      voteCount: map['voteCount'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'optionId': optionId,
      'text': text,
      'voteCount': voteCount,
      'percentage': percentage,
    };
  }
}

/// Model untuk demographics voting
class PollDemographics {
  final Map<String, int> byRT;
  final Map<String, int> byGender;
  final Map<String, int> byAgeGroup;

  PollDemographics({
    this.byRT = const {},
    this.byGender = const {},
    this.byAgeGroup = const {},
  });

  factory PollDemographics.fromMap(Map<String, dynamic> map) {
    return PollDemographics(
      byRT: Map<String, int>.from(map['byRT'] ?? {}),
      byGender: Map<String, int>.from(map['byGender'] ?? {}),
      byAgeGroup: Map<String, int>.from(map['byAgeGroup'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'byRT': byRT,
      'byGender': byGender,
      'byAgeGroup': byAgeGroup,
    };
  }
}

