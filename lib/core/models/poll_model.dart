import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Polling RT/RW
/// Mendukung polling resmi (admin) dan komunitas (warga)
class Poll {
  final String pollId;
  final String title;
  final String description;
  final String type; // "election" | "decision" | "survey"

  // Tipe Polling
  final String pollLevel; // "official" | "community"
  final String createdByRole; // "admin" | "warga"

  // Creator Info
  final String createdBy;
  final String createdByName;
  final String? createdByPhoto;

  // Dates
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // "draft" | "active" | "closed" | "cancelled"

  // Scope & Targeting
  final String visibilityScope; // "all_rt" | "specific_rt" | "specific_rw"
  final String? targetRT;
  final String? targetRW;

  // Settings
  final bool requireKYC;
  final bool isAnonymous;
  final bool allowMultipleVotes;
  final int maxVotesPerUser;
  final bool showResultsRealtime; // ALWAYS TRUE per requirement
  final bool showVoterList; // ALWAYS TRUE per requirement

  // Moderation
  final bool isPinned;
  final bool isModerated;
  final bool isReported;
  final int reportCount;
  final List<String> reportReasons;

  // Stats (denormalized for performance)
  final int totalVotes;
  final int totalParticipants;
  final int totalOptions;
  final DateTime? lastVoteAt;

  // Attachments
  final List<PollAttachment> attachments;

  // Metadata
  final Map<String, dynamic> metadata;

  Poll({
    required this.pollId,
    required this.title,
    required this.description,
    required this.type,
    required this.pollLevel,
    required this.createdByRole,
    required this.createdBy,
    required this.createdByName,
    this.createdByPhoto,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.visibilityScope = 'all_rt',
    this.targetRT,
    this.targetRW,
    this.requireKYC = true,
    this.isAnonymous = false,
    this.allowMultipleVotes = false,
    this.maxVotesPerUser = 1,
    this.showResultsRealtime = true,
    this.showVoterList = true,
    this.isPinned = false,
    this.isModerated = false,
    this.isReported = false,
    this.reportCount = 0,
    this.reportReasons = const [],
    this.totalVotes = 0,
    this.totalParticipants = 0,
    this.totalOptions = 0,
    this.lastVoteAt,
    this.attachments = const [],
    this.metadata = const {},
  });

  // Factory from Firestore
  factory Poll.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Poll.fromMap(data, doc.id);
  }

  factory Poll.fromMap(Map<String, dynamic> map, String pollId) {
    return Poll(
      pollId: pollId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'survey',
      pollLevel: map['pollLevel'] ?? 'community',
      createdByRole: map['createdByRole'] ?? 'warga',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdByPhoto: map['createdByPhoto'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      status: map['status'] ?? 'draft',
      visibilityScope: map['visibilityScope'] ?? 'all_rt',
      targetRT: map['targetRT'],
      targetRW: map['targetRW'],
      requireKYC: map['requireKYC'] ?? true,
      isAnonymous: map['isAnonymous'] ?? false,
      allowMultipleVotes: map['allowMultipleVotes'] ?? false,
      maxVotesPerUser: map['maxVotesPerUser'] ?? 1,
      showResultsRealtime: map['showResultsRealtime'] ?? true,
      showVoterList: map['showVoterList'] ?? true,
      isPinned: map['isPinned'] ?? false,
      isModerated: map['isModerated'] ?? false,
      isReported: map['isReported'] ?? false,
      reportCount: map['reportCount'] ?? 0,
      reportReasons: List<String>.from(map['reportReasons'] ?? []),
      totalVotes: map['totalVotes'] ?? 0,
      totalParticipants: map['totalParticipants'] ?? 0,
      totalOptions: map['totalOptions'] ?? 0,
      lastVoteAt: (map['lastVoteAt'] as Timestamp?)?.toDate(),
      attachments: (map['attachments'] as List<dynamic>?)
              ?.map((e) => PollAttachment.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'pollLevel': pollLevel,
      'createdByRole': createdByRole,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByPhoto': createdByPhoto,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'visibilityScope': visibilityScope,
      'targetRT': targetRT,
      'targetRW': targetRW,
      'requireKYC': requireKYC,
      'isAnonymous': isAnonymous,
      'allowMultipleVotes': allowMultipleVotes,
      'maxVotesPerUser': maxVotesPerUser,
      'showResultsRealtime': showResultsRealtime,
      'showVoterList': showVoterList,
      'isPinned': isPinned,
      'isModerated': isModerated,
      'isReported': isReported,
      'reportCount': reportCount,
      'reportReasons': reportReasons,
      'totalVotes': totalVotes,
      'totalParticipants': totalParticipants,
      'totalOptions': totalOptions,
      'lastVoteAt': lastVoteAt != null ? Timestamp.fromDate(lastVoteAt!) : null,
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'metadata': metadata,
    };
  }

  // Copy with
  Poll copyWith({
    String? pollId,
    String? title,
    String? description,
    String? type,
    String? pollLevel,
    String? createdByRole,
    String? createdBy,
    String? createdByName,
    String? createdByPhoto,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? visibilityScope,
    String? targetRT,
    String? targetRW,
    bool? requireKYC,
    bool? isAnonymous,
    bool? allowMultipleVotes,
    int? maxVotesPerUser,
    bool? showResultsRealtime,
    bool? showVoterList,
    bool? isPinned,
    bool? isModerated,
    bool? isReported,
    int? reportCount,
    List<String>? reportReasons,
    int? totalVotes,
    int? totalParticipants,
    int? totalOptions,
    DateTime? lastVoteAt,
    List<PollAttachment>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Poll(
      pollId: pollId ?? this.pollId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      pollLevel: pollLevel ?? this.pollLevel,
      createdByRole: createdByRole ?? this.createdByRole,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByPhoto: createdByPhoto ?? this.createdByPhoto,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      visibilityScope: visibilityScope ?? this.visibilityScope,
      targetRT: targetRT ?? this.targetRT,
      targetRW: targetRW ?? this.targetRW,
      requireKYC: requireKYC ?? this.requireKYC,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      allowMultipleVotes: allowMultipleVotes ?? this.allowMultipleVotes,
      maxVotesPerUser: maxVotesPerUser ?? this.maxVotesPerUser,
      showResultsRealtime: showResultsRealtime ?? this.showResultsRealtime,
      showVoterList: showVoterList ?? this.showVoterList,
      isPinned: isPinned ?? this.isPinned,
      isModerated: isModerated ?? this.isModerated,
      isReported: isReported ?? this.isReported,
      reportCount: reportCount ?? this.reportCount,
      reportReasons: reportReasons ?? this.reportReasons,
      totalVotes: totalVotes ?? this.totalVotes,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      totalOptions: totalOptions ?? this.totalOptions,
      lastVoteAt: lastVoteAt ?? this.lastVoteAt,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);
  bool get isClosed => status == 'closed' || DateTime.now().isAfter(endDate);
  bool get isOfficial => pollLevel == 'official';
  bool get isCommunity => pollLevel == 'community';

  Duration get timeRemaining => endDate.difference(DateTime.now());
  bool get isEndingSoon => timeRemaining.inHours < 24 && isActive;

  double get participationRate {
    // Calculate based on target scope - placeholder
    // Will need to inject total warga count
    return totalParticipants > 0 ? (totalVotes / totalParticipants * 100) : 0.0;
  }
}

/// Model untuk attachment pada polling
class PollAttachment {
  final String type; // "image" | "document" | "pdf"
  final String url;
  final String name;
  final int? size;

  PollAttachment({
    required this.type,
    required this.url,
    required this.name,
    this.size,
  });

  factory PollAttachment.fromMap(Map<String, dynamic> map) {
    return PollAttachment(
      type: map['type'] ?? 'image',
      url: map['url'] ?? '',
      name: map['name'] ?? '',
      size: map['size'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'name': name,
      'size': size,
    };
  }
}

