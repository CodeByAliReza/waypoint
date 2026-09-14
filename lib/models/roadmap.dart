import 'stage.dart';

class Roadmap {
  final String id;
  final String ambition;
  final String level;
  final int hoursPerWeek;
  final String createdAt;
  final List<Stage> stages;

  Roadmap({
    required this.id,
    required this.ambition,
    required this.level,
    required this.hoursPerWeek,
    required this.createdAt,
    required this.stages,
  });

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      id: json['id'] as String,
      ambition: json['ambition'] as String,
      level: json['level'] as String,
      hoursPerWeek: json['hoursPerWeek'] as int,
      createdAt: json['createdAt'] as String,
      stages: (json['stages'] as List)
          .map((s) => Stage.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  int get completedStages => stages.where((s) => s.completed).length;
  double get progress => stages.isEmpty ? 0 : completedStages / stages.length;
}
