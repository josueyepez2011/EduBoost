import 'package:equatable/equatable.dart';

enum GradeCategory { exam, homework, quiz, project, participation }

class GradeModel extends Equatable {
  final String id;
  final String subject;
  final double score;
  final double maxScore;
  final DateTime date;
  final GradeCategory category;
  final String? notes;

  const GradeModel({
    required this.id,
    required this.subject,
    required this.score,
    required this.maxScore,
    required this.date,
    required this.category,
    this.notes,
  });

  double get percentage => (score / maxScore) * 100;

  GradeModel copyWith({
    String? id,
    String? subject,
    double? score,
    double? maxScore,
    DateTime? date,
    GradeCategory? category,
    String? notes,
  }) {
    return GradeModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'score': score,
      'maxScore': maxScore,
      'date': date.toIso8601String(),
      'category': category.index,
      'notes': notes,
    };
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: GradeCategory.values[json['category'] as int],
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, subject, score, maxScore, date, category, notes];
}
