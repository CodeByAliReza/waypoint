import 'package:flutter/material.dart';
import '../models/roadmap.dart';
import '../models/stage.dart';
import '../services/api.dart';
import '../widgets/resource_tile.dart';

class StageDetail extends StatefulWidget {
  final Roadmap roadmap;
  final Stage stage;

  const StageDetail({
    super.key,
    required this.roadmap,
    required this.stage,
  });

  @override
  State<StageDetail> createState() => _StageDetailState();
}

class _StageDetailState extends State<StageDetail> {
  late bool _completed;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _completed = widget.stage.completed;
  }

  Future<void> _toggleComplete() async {
    setState(() => _updating = true);
    try {
      final updated = await ApiService.markStageComplete(
        roadmapId: widget.roadmap.id,
        stageId: widget.stage.id,
        completed: !_completed,
      );
      setState(() => _completed = updated.completed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stage ${widget.stage.order}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stage.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stage ${widget.stage.order} of ${widget.roadmap.stages.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Resources',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: widget.stage.resources.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ResourceTile(
                      resource: widget.stage.resources[index],
                      index: index,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _updating ? null : _toggleComplete,
                icon: _updating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_completed ? Icons.undo : Icons.check),
                label: Text(_completed ? 'Mark Incomplete' : 'Mark Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
