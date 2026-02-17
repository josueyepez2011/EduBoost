import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/grade_model.dart';
import '../../../core/services/local_storage_service.dart';

// Events
abstract class GradeEvent extends Equatable {
  const GradeEvent();

  @override
  List<Object?> get props => [];
}

class LoadGrades extends GradeEvent {}

class AddGrade extends GradeEvent {
  final GradeModel grade;
  const AddGrade(this.grade);

  @override
  List<Object?> get props => [grade];
}

class DeleteGrade extends GradeEvent {
  final String gradeId;
  const DeleteGrade(this.gradeId);

  @override
  List<Object?> get props => [gradeId];
}

// States
abstract class GradeState extends Equatable {
  const GradeState();

  @override
  List<Object?> get props => [];
}

class GradeInitial extends GradeState {}

class GradeLoading extends GradeState {}

class GradeLoaded extends GradeState {
  final List<GradeModel> grades;
  final double averageGrade;
  final Map<String, double> subjectAverages;

  const GradeLoaded({
    required this.grades,
    required this.averageGrade,
    required this.subjectAverages,
  });

  @override
  List<Object?> get props => [grades, averageGrade, subjectAverages];
}

class GradeAddedWithPerfectScore extends GradeLoaded {
  final GradeModel perfectGrade;

  const GradeAddedWithPerfectScore({
    required super.grades,
    required super.averageGrade,
    required super.subjectAverages,
    required this.perfectGrade,
  });

  @override
  List<Object?> get props => [
    grades,
    averageGrade,
    subjectAverages,
    perfectGrade,
  ];
}

class GradeAddedWithGoodScore extends GradeLoaded {
  final GradeModel goodGrade;

  const GradeAddedWithGoodScore({
    required super.grades,
    required super.averageGrade,
    required super.subjectAverages,
    required this.goodGrade,
  });

  @override
  List<Object?> get props => [grades, averageGrade, subjectAverages, goodGrade];
}

class GradeAddedWithImprovement extends GradeLoaded {
  final GradeModel improvedGrade;
  final double previousAverage;

  const GradeAddedWithImprovement({
    required super.grades,
    required super.averageGrade,
    required super.subjectAverages,
    required this.improvedGrade,
    required this.previousAverage,
  });

  @override
  List<Object?> get props => [
    grades,
    averageGrade,
    subjectAverages,
    improvedGrade,
    previousAverage,
  ];
}

class GradeError extends GradeState {
  final String message;
  const GradeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GradeBloc extends Bloc<GradeEvent, GradeState> {
  final LocalStorageService storageService;

  GradeBloc(this.storageService) : super(GradeInitial()) {
    on<LoadGrades>(_onLoadGrades);
    on<AddGrade>(_onAddGrade);
    on<DeleteGrade>(_onDeleteGrade);
  }

  Future<void> _onLoadGrades(LoadGrades event, Emitter<GradeState> emit) async {
    try {
      emit(GradeLoading());
      final gradesJson = storageService.getGrades();
      final grades = gradesJson
          .map((json) => GradeModel.fromJson(json))
          .toList();

      // Sort by date (newest first)
      grades.sort((a, b) => b.date.compareTo(a.date));

      // Calculate statistics
      final stats = _calculateStatistics(grades);

      emit(
        GradeLoaded(
          grades: grades,
          averageGrade: stats['average'] as double,
          subjectAverages: stats['subjectAverages'] as Map<String, double>,
        ),
      );
    } catch (e) {
      emit(GradeError(e.toString()));
    }
  }

  Future<void> _onAddGrade(AddGrade event, Emitter<GradeState> emit) async {
    try {
      final currentState = state;
      if (currentState is GradeLoaded) {
        // Calculate previous subject average before adding new grade
        final previousGradesForSubject = currentState.grades
            .where((g) => g.subject == event.grade.subject)
            .toList();
        
        final previousSubjectAverage = previousGradesForSubject.isEmpty
            ? 0.0
            : previousGradesForSubject
                .map((g) => g.percentage)
                .reduce((a, b) => a + b) / previousGradesForSubject.length;

        final updatedGrades = List<GradeModel>.from(currentState.grades)
          ..add(event.grade);
        updatedGrades.sort((a, b) => b.date.compareTo(a.date));

        await storageService.saveGrades(
          updatedGrades.map((grade) => grade.toJson()).toList(),
        );

        final stats = _calculateStatistics(updatedGrades);

        // Check if the grade is perfect (100%) and is exam, quiz, or participation
        final isPerfectScore = event.grade.score == event.grade.maxScore;
        final isRelevantCategory =
            event.grade.category == GradeCategory.exam ||
            event.grade.category == GradeCategory.quiz ||
            event.grade.category == GradeCategory.participation;

        // Check if the grade is good (more than 60%)
        final isGoodGrade = event.grade.percentage >= 60.0;

        // Check if grade shows improvement (better than previous average for that subject)
        final isImprovement = previousGradesForSubject.isNotEmpty &&
            event.grade.percentage > previousSubjectAverage;

        if (isPerfectScore && isRelevantCategory) {
          emit(
            GradeAddedWithPerfectScore(
              grades: updatedGrades,
              averageGrade: stats['average'] as double,
              subjectAverages: stats['subjectAverages'] as Map<String, double>,
              perfectGrade: event.grade,
            ),
          );
        } else if (isImprovement) {
          emit(
            GradeAddedWithImprovement(
              grades: updatedGrades,
              averageGrade: stats['average'] as double,
              subjectAverages: stats['subjectAverages'] as Map<String, double>,
              improvedGrade: event.grade,
              previousAverage: previousSubjectAverage,
            ),
          );
        } else if (isGoodGrade) {
          emit(
            GradeAddedWithGoodScore(
              grades: updatedGrades,
              averageGrade: stats['average'] as double,
              subjectAverages: stats['subjectAverages'] as Map<String, double>,
              goodGrade: event.grade,
            ),
          );
        } else {
          emit(
            GradeLoaded(
              grades: updatedGrades,
              averageGrade: stats['average'] as double,
              subjectAverages: stats['subjectAverages'] as Map<String, double>,
            ),
          );
        }
      }
    } catch (e) {
      emit(GradeError(e.toString()));
    }
  }

  Future<void> _onDeleteGrade(
    DeleteGrade event,
    Emitter<GradeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is GradeLoaded) {
        final updatedGrades = currentState.grades
            .where((grade) => grade.id != event.gradeId)
            .toList();

        await storageService.saveGrades(
          updatedGrades.map((grade) => grade.toJson()).toList(),
        );

        final stats = _calculateStatistics(updatedGrades);

        emit(
          GradeLoaded(
            grades: updatedGrades,
            averageGrade: stats['average'] as double,
            subjectAverages: stats['subjectAverages'] as Map<String, double>,
          ),
        );
      }
    } catch (e) {
      emit(GradeError(e.toString()));
    }
  }

  Map<String, dynamic> _calculateStatistics(List<GradeModel> grades) {
    if (grades.isEmpty) {
      return {'average': 0.0, 'subjectAverages': <String, double>{}};
    }

    // Calculate overall average
    final totalPercentage = grades.fold<double>(
      0,
      (sum, grade) => sum + grade.percentage,
    );
    final average = totalPercentage / grades.length;

    // Calculate subject averages
    final Map<String, List<double>> subjectScores = {};
    for (final grade in grades) {
      subjectScores.putIfAbsent(grade.subject, () => []);
      subjectScores[grade.subject]!.add(grade.percentage);
    }

    final Map<String, double> subjectAverages = {};
    subjectScores.forEach((subject, scores) {
      final subjectAvg = scores.reduce((a, b) => a + b) / scores.length;
      subjectAverages[subject] = subjectAvg;
    });

    return {'average': average, 'subjectAverages': subjectAverages};
  }
}
