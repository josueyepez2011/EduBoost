import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/achievement_model.dart';
import '../../../core/services/local_storage_service.dart';

// Events
abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAchievements extends AchievementEvent {}

class UpdateAchievementProgress extends AchievementEvent {
  final String achievementId;
  final int increment;
  
  const UpdateAchievementProgress(this.achievementId, {this.increment = 1});

  @override
  List<Object?> get props => [achievementId, increment];
}

class UnlockAchievement extends AchievementEvent {
  final String achievementId;
  const UnlockAchievement(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
}

// States
abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object?> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<AchievementModel> achievements;
  final AchievementModel? newlyUnlocked;

  const AchievementLoaded({
    required this.achievements,
    this.newlyUnlocked,
  });

  @override
  List<Object?> get props => [achievements, newlyUnlocked];
}

class AchievementError extends AchievementState {
  final String message;
  const AchievementError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final LocalStorageService storageService;

  AchievementBloc(this.storageService) : super(AchievementInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<UpdateAchievementProgress>(_onUpdateAchievementProgress);
    on<UnlockAchievement>(_onUnlockAchievement);
  }

  Future<void> _onLoadAchievements(
      LoadAchievements event, Emitter<AchievementState> emit) async {
    try {
      emit(AchievementLoading());
      final achievementsJson = storageService.getAchievements();
      
      List<AchievementModel> achievements;
      if (achievementsJson.isEmpty) {
        // Initialize default achievements
        achievements = _getDefaultAchievements();
        await storageService.saveAchievements(
          achievements.map((a) => a.toJson()).toList(),
        );
      } else {
        achievements = achievementsJson
            .map((json) => AchievementModel.fromJson(json))
            .toList();
        
        // Check if we need to add new achievements (migration)
        final defaultAchievements = _getDefaultAchievements();
        final existingIds = achievements.map((a) => a.id).toSet();
        final missingAchievements = defaultAchievements
            .where((a) => !existingIds.contains(a.id))
            .toList();
        
        if (missingAchievements.isNotEmpty) {
          achievements.addAll(missingAchievements);
          await storageService.saveAchievements(
            achievements.map((a) => a.toJson()).toList(),
          );
        }
      }
      
      emit(AchievementLoaded(achievements: achievements));
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  Future<void> _onUpdateAchievementProgress(
      UpdateAchievementProgress event, Emitter<AchievementState> emit) async {
    try {
      final currentState = state;
      if (currentState is AchievementLoaded) {
        AchievementModel? newlyUnlocked;
        
        final updatedAchievements = currentState.achievements.map((achievement) {
          if (achievement.id == event.achievementId && !achievement.isUnlocked) {
            final newCount = achievement.currentCount + event.increment;
            final updated = achievement.copyWith(currentCount: newCount);
            
            // Check if achievement should be unlocked
            if (newCount >= achievement.requiredCount) {
              newlyUnlocked = updated.copyWith(
                isUnlocked: true,
                unlockedDate: DateTime.now(),
              );
              return newlyUnlocked!;
            }
            return updated;
          }
          return achievement;
        }).toList();
        
        await storageService.saveAchievements(
          updatedAchievements.map((a) => a.toJson()).toList(),
        );
        
        emit(AchievementLoaded(
          achievements: updatedAchievements,
          newlyUnlocked: newlyUnlocked,
        ));
      }
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  Future<void> _onUnlockAchievement(
      UnlockAchievement event, Emitter<AchievementState> emit) async {
    try {
      final currentState = state;
      if (currentState is AchievementLoaded) {
        final updatedAchievements = currentState.achievements.map((achievement) {
          if (achievement.id == event.achievementId) {
            return achievement.copyWith(
              isUnlocked: true,
              unlockedDate: DateTime.now(),
            );
          }
          return achievement;
        }).toList();
        
        await storageService.saveAchievements(
          updatedAchievements.map((a) => a.toJson()).toList(),
        );
        
        emit(AchievementLoaded(achievements: updatedAchievements));
      }
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  List<AchievementModel> _getDefaultAchievements() {
    return [
      const AchievementModel(
        id: 'first_task',
        title: 'Primeros Pasos',
        description: 'Completa tu primera tarea',
        icon: '✅',
        isUnlocked: false,
        requiredCount: 1,
      ),
      const AchievementModel(
        id: 'task_master',
        title: 'Maestro de Tareas',
        description: 'Completa 10 tareas',
        icon: '🎯',
        isUnlocked: false,
        requiredCount: 10,
      ),
      const AchievementModel(
        id: 'perfect_score',
        title: 'Puntuación Perfecta',
        description: 'Obtén un 100% en un examen, quiz o participación',
        icon: '💯',
        isUnlocked: false,
        requiredCount: 1,
      ),
      const AchievementModel(
        id: 'week_streak',
        title: 'Estudiante Constante',
        description: 'Obtén 7 buenas notas (más del 60%)',
        icon: '🔥',
        isUnlocked: false,
        requiredCount: 7,
      ),
      const AchievementModel(
        id: 'grade_improved',
        title: 'Estrella en Ascenso',
        description: 'Mejora tus notas 10 veces',
        icon: '⭐',
        isUnlocked: false,
        requiredCount: 10,
      ),
    ];
  }
}
