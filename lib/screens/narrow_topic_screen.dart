import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/narrow_topic.dart';
import '../providers/api_key_provider.dart';
import '../providers/generation_provider.dart';
import '../providers/preference_providers.dart';
import '../services/mistral_client.dart';
import '../widgets/output/narrow_topic_view.dart';
import '../widgets/output/status_banner.dart';

/// Dedicated detail page for a single narrow topic produced by Deep Dive.
///
/// Deliberately keeps its own local topic/refine state instead of the
/// shared [generationProvider] response, so navigating here (and back) never
/// disturbs whatever broad topics list is still showing underneath.
class NarrowTopicScreen extends ConsumerStatefulWidget {
  final NarrowTopic initialTopic;
  final List<String> fieldsCovered;
  final String language;

  const NarrowTopicScreen({
    super.key,
    required this.initialTopic,
    required this.fieldsCovered,
    required this.language,
  });

  @override
  ConsumerState<NarrowTopicScreen> createState() => _NarrowTopicScreenState();
}

class _NarrowTopicScreenState extends ConsumerState<NarrowTopicScreen> {
  late NarrowTopic _topic;
  bool _isRefining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _topic = widget.initialTopic;
  }

  Future<void> _refine(String instruction) async {
    final apiKey = ref.read(apiKeyProvider).key;
    if (apiKey == null || apiKey.isEmpty) {
      setState(() => _error = 'No API key is set. Please unlock the app again.');
      return;
    }
    final prefs = ref.read(preferenceBlockProvider);
    final client = ref.read(mistralClientProvider);

    setState(() {
      _isRefining = true;
      _error = null;
    });
    try {
      final updated = await client.refine(
        apiKey: apiKey,
        prefs: prefs,
        currentTopic: _topic,
        refinementInstruction: instruction,
      );
      setState(() {
        _topic = updated;
        _isRefining = false;
      });
    } on ApiKeyRejectedException catch (e) {
      ref.read(keyRejectedMessageProvider.notifier).state = e.message;
      ref.read(apiKeyProvider.notifier).forget();
      if (mounted) Navigator.of(context).pop();
    } on MistralApiException catch (e) {
      setState(() {
        _isRefining = false;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _isRefining = false;
        _error = 'Something went wrong while refining this topic.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_topic.title, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  StatusBanner(
                    message: _error!,
                    onDismiss: () => setState(() => _error = null),
                  ),
                NarrowTopicView(
                  topic: _topic,
                  fieldsCovered: widget.fieldsCovered,
                  language: widget.language,
                  isRefining: _isRefining,
                  onRefine: _refine,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
