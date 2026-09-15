import 'package:flutter/material.dart';
import 'models/roadmap.dart';
import 'services/api.dart';
import 'screens/ambition_input.dart';
import 'screens/roadmap_list.dart';

void main() {
  runApp(const WaypointApp());
}

class WaypointApp extends StatelessWidget {
  const WaypointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waypoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2D6A4F),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF2D6A4F),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      routes: {
        '/ambition': (context) => const AmbitionInputScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/roadmap') {
          final roadmap = settings.arguments as Roadmap;
          return MaterialPageRoute(
            builder: (_) => RoadmapScreen(roadmap: roadmap),
          );
        }
        return null;
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Roadmap? _roadmap;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    try {
      final roadmap = await ApiService.getActiveRoadmap();
      if (mounted) setState(() => _roadmap = roadmap);
    } catch (_) {
      // No roadmap yet
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_roadmap != null) {
      return RoadmapScreen(roadmap: _roadmap!);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Waypoint',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'One ambition.\nOne roadmap.\nThree resources per stage.\nNothing else.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ambition');
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
