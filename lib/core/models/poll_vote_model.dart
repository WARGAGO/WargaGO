import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk vote/suara dalam polling
class PollVote {
  final String voteId;
  final String pollId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? userRT;
  final String? userRW;

  final String optionId;
  final String optionText; // denormalized for speed

  final DateTime votedAt;
  final bool isAnonymous;

  // Audit trail
  final String? ipAddress;
  final String? deviceInfo;

  // Metadata
  final Map<String, dynamic> metadata;

  PollVote({
    required this.voteId,
    required this.pollId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.userRT,
    this.userRW,
    required this.optionId,
    required this.optionText,
    required this.votedAt,
    this.isAnonymous = false,
    this.ipAddress,
    this.deviceInfo,
    this.metadata = const {},
  });

  // Factory from Firestore
  factory PollVote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PollVote.fromMap(data, doc.id);
  }

  factory PollVote.fromMap(Map<String, dynamic> map, String voteId) {
    return PollVote(
      voteId: voteId,
      pollId: map['pollId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhoto: map['userPhoto'],
      userRT: map['userRT'],
      userRW: map['userRW'],
      optionId: map['optionId'] ?? '',
      optionText: map['optionText'] ?? '',
      votedAt: (map['votedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: map['isAnonymous'] ?? false,
      ipAddress: map['ipAddress'],
      deviceInfo: map['deviceInfo'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'pollId': pollId,
      'userId': userId,
      'userName': isAnonymous ? '' : userName,
      'userPhoto': isAnonymous ? '' : userPhoto,
      'userRT': userRT,
      'userRW': userRW,
      'optionId': optionId,
      'optionText': optionText,
      'votedAt': Timestamp.fromDate(votedAt),
      'isAnonymous': isAnonymous,
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
      'metadata': metadata,
    };
  }

  // Copy with
  PollVote copyWith({
    String? voteId,
    String? pollId,
    String? userId,
    String? userName,
    String? userPhoto,
    String? userRT,
    String? userRW,
    String? optionId,
    String? optionText,
    DateTime? votedAt,
    bool? isAnonymous,
    String? ipAddress,
    String? deviceInfo,
    Map<String, dynamic>? metadata,
  }) {
    return PollVote(
      voteId: voteId ?? this.voteId,
      pollId: pollId ?? this.pollId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      userRT: userRT ?? this.userRT,
      userRW: userRW ?? this.userRW,
      optionId: optionId ?? this.optionId,
      optionText: optionText ?? this.optionText,
      votedAt: votedAt ?? this.votedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get hasKYC => metadata['hasKYC'] == true;
  String get displayName => isAnonymous ? 'Anonim' : userName;
}

