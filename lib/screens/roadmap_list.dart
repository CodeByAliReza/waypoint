import 'package:flutter/material.dart';
import '../models/roadmap.dart';
import '../widgets/stage_card.dart';
import 'stage_detail.dart';
import 'progress.dart';

class RoadmapScreen extends StatelessWidget {
  final Roadmap roadmap;

  const RoadmapScreen({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roadmap.ambition),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgressScreen(roadmap: roadmap),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${roadmap.completedStages} of ${roadmap.stages.length} stages complete',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: roadmap.progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: roadmap.stages.length,
              itemBuilder: (context, index) {
                final stage = roadmap.stages[index];
                return StageCard(
                  stage: stage,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StageDetail(
                          roadmap: roadmap,
                          stage: stage,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
