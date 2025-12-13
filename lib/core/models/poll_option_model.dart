import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk pilihan/opsi dalam polling
class PollOption {
  final String optionId;
  final String pollId;
  final String text;
  final String? description;
  final String? imageUrl;
  final int order;

  // For election type - info kandidat
  final CandidateInfo? candidateInfo;

  // Stats (denormalized for real-time performance)
  final int voteCount;
  final double percentage;
  final DateTime lastUpdated;

  PollOption({
    required this.optionId,
    required this.pollId,
    required this.text,
    this.description,
    this.imageUrl,
    required this.order,
    this.candidateInfo,
    this.voteCount = 0,
    this.percentage = 0.0,
    required this.lastUpdated,
  });

  // Factory from Firestore
  factory PollOption.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PollOption.fromMap(data, doc.id);
  }

  factory PollOption.fromMap(Map<String, dynamic> map, String optionId) {
    return PollOption(
      optionId: optionId,
      pollId: map['pollId'] ?? '',
      text: map['text'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      order: map['order'] ?? 0,
      candidateInfo: map['candidateInfo'] != null
          ? CandidateInfo.fromMap(map['candidateInfo'] as Map<String, dynamic>)
          : null,
      voteCount: map['voteCount'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'pollId': pollId,
      'text': text,
      'description': description,
      'imageUrl': imageUrl,
      'order': order,
      'candidateInfo': candidateInfo?.toMap(),
      'voteCount': voteCount,
      'percentage': percentage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Copy with
  PollOption copyWith({
    String? optionId,
    String? pollId,
    String? text,
    String? description,
    String? imageUrl,
    int? order,
    CandidateInfo? candidateInfo,
    int? voteCount,
    double? percentage,
    DateTime? lastUpdated,
  }) {
    return PollOption(
      optionId: optionId ?? this.optionId,
      pollId: pollId ?? this.pollId,
      text: text ?? this.text,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      candidateInfo: candidateInfo ?? this.candidateInfo,
      voteCount: voteCount ?? this.voteCount,
      percentage: percentage ?? this.percentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper methods
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get isCandidate => candidateInfo != null;
}

/// Model untuk informasi kandidat (untuk polling election)
class CandidateInfo {
  final int? age;
  final String? occupation;
  final String? experience;
  final String? vision;
  final String? mission;
  final List<String> achievements;

  CandidateInfo({
    this.age,
    this.occupation,
    this.experience,
    this.vision,
    this.mission,
    this.achievements = const [],
  });

  factory CandidateInfo.fromMap(Map<String, dynamic> map) {
    return CandidateInfo(
      age: map['age'],
      occupation: map['occupation'],
      experience: map['experience'],
      vision: map['vision'],
      mission: map['mission'],
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'occupation': occupation,
      'experience': experience,
      'vision': vision,
      'mission': mission,
      'achievements': achievements,
    };
  }
}

