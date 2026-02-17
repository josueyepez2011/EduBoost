import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../bloc/grade_bloc.dart';
import '../data/models/grade_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/custom_button.dart';

class AddGradeScreen extends StatefulWidget {
  const AddGradeScreen({super.key});

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _scoreController;
  late TextEditingController _maxScoreController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late GradeCategory _selectedCategory;
  late String _selectedSubject;

  final List<String> subjects = [
    'Matemáticas',
    'Ciencias',
    'Inglés',
    'Historia',
    'Geografía',
    'Física',
    'Química',
    'Biología',
    'Informática',
    'Arte',
  ];

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController();
    _maxScoreController = TextEditingController(text: '100');
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedCategory = GradeCategory.exam;
    _selectedSubject = subjects[0];
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _maxScoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getCategoryName(GradeCategory category) {
    switch (category) {
      case GradeCategory.exam:
        return 'Examen';
      case GradeCategory.homework:
        return 'Tarea';
      case GradeCategory.quiz:
        return 'Prueba';
      case GradeCategory.project:
        return 'Proyecto';
      case GradeCategory.participation:
        return 'Participación';
    }
  }

  void _saveGrade() {
    if (_formKey.currentState!.validate()) {
      final grade = GradeModel(
        id: const Uuid().v4(),
        subject: _selectedSubject,
        score: double.parse(_scoreController.text),
        maxScore: double.parse(_maxScoreController.text),
        date: _selectedDate,
        category: _selectedCategory,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<GradeBloc>().add(AddGrade(grade));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nueva Nota',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Materia',
                  ),
                  items: subjects
                      .map((subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value!;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _scoreController,
                        decoration: const InputDecoration(
                          labelText: 'Puntuación',
                          hintText: '0',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final score = double.tryParse(value);
                          if (score == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxScoreController,
                        decoration: const InputDecoration(
                          labelText: 'Puntuación Máxima',
                          hintText: '100',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final maxScore = double.tryParse(value);
                          if (maxScore == null || maxScore <= 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                DropdownButtonFormField<GradeCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                  ),
                  items: GradeCategory.values
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryName(category)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.spacing16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Opcional)',
                    hintText: 'Agrega notas sobre esta calificación',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.spacing32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Agregar Nota',
                    onPressed: _saveGrade,
                    icon: Icons.check,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
