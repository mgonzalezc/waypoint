import 'package:flutter/material.dart';

import 'data/ranking/direct_openai_ranking_repository.dart';
import 'data/services/openai_service.dart';
import 'domain/ranking/ranking_failure.dart';
import 'domain/ranking/ranking_repository.dart';
import 'domain/ranking/ranking_result.dart';
import 'ui/design_system/theming/waypoint_theme.dart';

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
      theme: buildWaypointTheme(),
      home: const _ManualRankingTestScreen(),
    );
  }
}

class _ManualRankingTestScreen extends StatefulWidget {
  const _ManualRankingTestScreen();

  @override
  State<_ManualRankingTestScreen> createState() => _ManualRankingTestScreenState();
}

class _ManualRankingTestScreenState extends State<_ManualRankingTestScreen> {
  final _controller = TextEditingController();
  final RankingRepository _repository = DirectOpenAiRankingRepository(
    OpenAiService(OpenAiService.buildClient()),
  );

  bool _loading = false;
  RankingResult? _result;
  Object? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await _repository.generateRanking(query: query, locale: 'es');
      setState(() => _result = result);
    } catch (error) {
      setState(() => _error = error);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ranking generation — manual test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'top 10 tapas bars in Seville...',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'generating...' : 'generate'),
            ),
            const SizedBox(height: 16),
            if (_error != null) Text('Error: ${_describeError(_error!)}'),
            if (_result != null)
              Expanded(
                child: ListView(
                  children: [
                    if (_result!.degraded)
                      const Text('(fewer than 10 good candidates)'),
                    for (final item in _result!.items)
                      ListTile(
                        title: Text('${item.position}. ${item.name}'),
                        subtitle: Text(item.reason),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _describeError(Object error) => switch (error) {
    NoConnection() => 'no connection',
    ServiceUnavailable() => 'service unavailable',
    RateLimited() => 'rate limited',
    UnexpectedFailure(:final message) => 'unexpected: $message',
    _ => error.toString(),
  };
}
