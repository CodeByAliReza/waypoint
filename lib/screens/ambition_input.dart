import 'package:flutter/material.dart';
import '../services/api.dart';

class AmbitionInputScreen extends StatefulWidget {
  const AmbitionInputScreen({super.key});

  @override
  State<AmbitionInputScreen> createState() => _AmbitionInputScreenState();
}

class _AmbitionInputScreenState extends State<AmbitionInputScreen> {
  final _ambitionController = TextEditingController();
  String _selectedLevel = 'Beginner';
  int _selectedHours = 5;
  bool _loading = false;
  String? _error;

  final _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final _hours = [2, 5, 10, 15, 20];

  @override
  void dispose() {
    _ambitionController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final ambition = _ambitionController.text.trim();
    if (ambition.isEmpty) {
      setState(() => _error = 'Please enter your ambition');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final roadmap = await ApiService.generateRoadmap(
        ambition: ambition,
        level: _selectedLevel,
        hoursPerWeek: _selectedHours,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/roadmap', arguments: roadmap);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'What do you\nwant to become?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _ambitionController,
                decoration: const InputDecoration(
                  labelText: 'Your ambition',
                  hintText: 'e.g. Data Analyst, Web Developer, UX Designer',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _generate(),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Current level',
                  border: OutlineInputBorder(),
                ),
                items: _levels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLevel = v!),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                initialValue: _selectedHours,
                decoration: const InputDecoration(
                  labelText: 'Hours per week',
                  border: OutlineInputBorder(),
                ),
                items: _hours
                    .map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('$h hours'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedHours = v!),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: _loading ? null : _generate,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate Roadmap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
