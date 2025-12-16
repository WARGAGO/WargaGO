/// Model class untuk Notulen
class NotulenModel {
  final String id;
  final String date;
  final String time;
  final String title;
  final String location;
  final int attendees;
  final int topics;
  final int decisions;
  final String type; // 'recent', 'archived'
  final String agenda;
  final String discussion;
  final String decisionsText;
  final String actionItems;

  NotulenModel({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.attendees,
    required this.topics,
    required this.decisions,
    required this.type,
    required this.agenda,
    required this.discussion,
    required this.decisionsText,
    required this.actionItems,
  });

  // Copy method untuk update data
  NotulenModel copyWith({
    String? id,
    String? date,
    String? time,
    String? title,
    String? location,
    int? attendees,
    int? topics,
    int? decisions,
    String? type,
    String? agenda,
    String? discussion,
    String? decisionsText,
    String? actionItems,
  }) {
    return NotulenModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      topics: topics ?? this.topics,
      decisions: decisions ?? this.decisions,
      type: type ?? this.type,
      agenda: agenda ?? this.agenda,
      discussion: discussion ?? this.discussion,
      decisionsText: decisionsText ?? this.decisionsText,
      actionItems: actionItems ?? this.actionItems,
    );
  }
}
