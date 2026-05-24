class Complaint {
  final String id;
  final String category;
  final String description;
  final String status;
  final DateTime date;
  final String? reply;

  const Complaint({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
    required this.date,
    this.reply,
  });

  Complaint copyWith({
    String? status,
    String? reply,
  }) {
    return Complaint(
      id: id,
      category: category,
      description: description,
      status: status ?? this.status,
      date: date,
      reply: reply ?? this.reply,
    );
  }
}
