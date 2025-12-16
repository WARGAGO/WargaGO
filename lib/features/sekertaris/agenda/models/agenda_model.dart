/// Model class untuk Agenda
class AgendaModel {
  final String id;
  final String date;
  final String time;
  final String title;
  final String location;
  final String description;
  final String status; 
  final int attendees;

  AgendaModel({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.status,
    required this.attendees,
  });

  // Copyy method untuk update data
  AgendaModel copyWith({
    String? id,
    String? date,
    String? time,
    String? title,
    String? location,
    String? description,
    String? status,
    int? attendees,
  }) {
    return AgendaModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      status: status ?? this.status,
      attendees: attendees ?? this.attendees,
    );
  }
}
