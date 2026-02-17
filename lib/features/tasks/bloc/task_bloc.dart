import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/task_model.dart';
import '../../../core/services/local_storage_service.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;
  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;
  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskComplete extends TaskEvent {
  final String taskId;
  const ToggleTaskComplete(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  const TaskLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskCompletedWithAchievement extends TaskLoaded {
  final TaskModel completedTask;
  const TaskCompletedWithAchievement(super.tasks, this.completedTask);

  @override
  List<Object?> get props => [tasks, completedTask];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final LocalStorageService storageService;

  TaskBloc(this.storageService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskComplete>(_onToggleTaskComplete);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      final tasksJson = storageService.getTasks();
      final tasks = tasksJson.map((json) => TaskModel.fromJson(json)).toList();

      // Sort by due date
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTasks = List<TaskModel>.from(currentState.tasks)
          ..add(event.task);
        updatedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        await storageService.saveTasks(
          updatedTasks.map((task) => task.toJson()).toList(),
        );

        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTasks = currentState.tasks.map((task) {
          return task.id == event.task.id ? event.task : task;
        }).toList();

        updatedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        await storageService.saveTasks(
          updatedTasks.map((task) => task.toJson()).toList(),
        );

        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTasks = currentState.tasks
            .where((task) => task.id != event.taskId)
            .toList();

        await storageService.saveTasks(
          updatedTasks.map((task) => task.toJson()).toList(),
        );

        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTaskComplete(
    ToggleTaskComplete event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        TaskModel? completedTask;
        final updatedTasks = currentState.tasks.map((task) {
          if (task.id == event.taskId) {
            final updated = task.copyWith(isCompleted: !task.isCompleted);
            if (updated.isCompleted && !task.isCompleted) {
              completedTask = updated;
            }
            return updated;
          }
          return task;
        }).toList();

        await storageService.saveTasks(
          updatedTasks.map((task) => task.toJson()).toList(),
        );

        emit(TaskLoaded(updatedTasks));

        // Update achievement progress when a task is completed
        if (completedTask != null) {
          emit(TaskCompletedWithAchievement(updatedTasks, completedTask!));
        }
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
