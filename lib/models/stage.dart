class Stage {
  final String id;
  final int order;
  final String title;
  final List<String> resources;
  final bool completed;

  Stage({
    required this.id,
    required this.order,
    required this.title,
    required this.resources,
    required this.completed,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      resources: (json['resources'] as List).cast<String>(),
      completed: json['completed'] as bool,
    );
  }
}
