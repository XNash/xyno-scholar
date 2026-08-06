import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/broad_topic.dart';
import '../models/enums.dart';
import '../models/generation_response.dart';
import '../models/narrow_topic.dart';
import '../services/mistral_client.dart';
import 'api_key_provider.dart';
import 'preference_providers.dart';

final mistralClientProvider = Provider<MistralClient>((ref) {
  final client = MistralClient();
  ref.onDispose(client.dispose);
  return client;
});

class GenerationState {
  final bool isLoading;
  final String? error;
  final GenerationResponse? response;
  final bool isRefining;
  final String? activeDeepDiveId;
  final BroadTopic? failedDeepDiveTopic;

  const GenerationState({
    this.isLoading = false,
    this.error,
    this.response,
    this.isRefining = false,
    this.activeDeepDiveId,
    this.failedDeepDiveTopic,
  });

  GenerationState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    GenerationResponse? response,
    bool? isRefining,
    String? activeDeepDiveId,
    bool clearActiveDeepDiveId = false,
    BroadTopic? failedDeepDiveTopic,
    bool clearFailedDeepDiveTopic = false,
  }) {
    return GenerationState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      response: response ?? this.response,
      isRefining: isRefining ?? this.isRefining,
      activeDeepDiveId: clearActiveDeepDiveId
          ? null
          : (activeDeepDiveId ?? this.activeDeepDiveId),
      failedDeepDiveTopic: clearFailedDeepDiveTopic
          ? null
          : (failedDeepDiveTopic ?? this.failedDeepDiveTopic),
    );
  }
}

class GenerationController extends Notifier<GenerationState> {
  @override
  GenerationState build() => const GenerationState();

  Future<void> _run(Future<GenerationResponse> Function() call) async {
    final apiKey = ref.read(apiKeyProvider).key;
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'No API key is set. Please unlock the app again.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await call();
      state = state.copyWith(isLoading: false, response: response);
    } on ApiKeyRejectedException catch (e) {
      ref.read(keyRejectedMessageProvider.notifier).state = e.message;
      ref.read(apiKeyProvider.notifier).forget();
      state = state.copyWith(isLoading: false, clearError: true);
    } on MistralApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong while talking to Mistral.',
      );
    }
  }

  Future<void> generate() async {
    final apiKey = ref.read(apiKeyProvider).key;
    final prefs = ref.read(preferenceBlockProvider);
    final freeText = ref.read(freeTextProvider);
    final client = ref.read(mistralClientProvider);
    await _run(
      () => client.generate(apiKey: apiKey!, prefs: prefs, freeText: freeText),
    );
  }

  Future<void> deepDive(BroadTopic topic) async {
    final apiKey = ref.read(apiKeyProvider).key;
    final prefs = ref.read(preferenceBlockProvider);
    final client = ref.read(mistralClientProvider);
    state = state.copyWith(
      activeDeepDiveId: topic.id,
      clearFailedDeepDiveTopic: true,
    );
    try {
      await _run(
        () => client.generate(
          apiKey: apiKey!,
          // Deep dive always requests a single narrow topic seeded with the
          // clicked broad topic, regardless of the sidebar's broad/narrow
          // scope toggle - hence the explicit override here.
          prefs: prefs.copyWith(scope: Scope.narrow),
          freeText: topic.keyKeywords.join(', '),
          deepDiveOnTitle: topic.title,
        ),
      );
      if (state.error != null) {
        state = state.copyWith(failedDeepDiveTopic: topic);
      }
    } finally {
      state = state.copyWith(clearActiveDeepDiveId: true);
    }
  }

  Future<void> refine(NarrowTopic topic, String instruction) async {
    final apiKey = ref.read(apiKeyProvider).key;
    if (apiKey == null || apiKey.isEmpty) return;
    final prefs = ref.read(preferenceBlockProvider);
    final client = ref.read(mistralClientProvider);

    state = state.copyWith(isLoading: true, isRefining: true, clearError: true);
    try {
      final updated = await client.refine(
        apiKey: apiKey,
        prefs: prefs,
        currentTopic: topic,
        refinementInstruction: instruction,
      );
      final current = state.response;
      state = state.copyWith(
        isLoading: false,
        isRefining: false,
        response: GenerationResponse(
          scope: 'narrow',
          language: current?.language ?? prefs.language,
          fieldsCovered: current?.fieldsCovered ?? prefs.fields,
          narrowTopic: updated,
        ),
      );
    } on ApiKeyRejectedException catch (e) {
      ref.read(keyRejectedMessageProvider.notifier).state = e.message;
      ref.read(apiKeyProvider.notifier).forget();
      state = state.copyWith(
        isLoading: false,
        isRefining: false,
        clearError: true,
      );
    } on MistralApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefining: false,
        error: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefining: false,
        error: 'Something went wrong while refining this topic.',
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  void reset() => state = const GenerationState();
}

final generationProvider =
    NotifierProvider<GenerationController, GenerationState>(
      GenerationController.new,
    );
