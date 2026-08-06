import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_storage.dart';

class ApiKeyState {
  final String? key;
  final bool rememberedForSession;

  const ApiKeyState({this.key, this.rememberedForSession = false});

  bool get isUnlocked => key != null && key!.isNotEmpty;

  ApiKeyState copyWith({String? key, bool? rememberedForSession}) {
    return ApiKeyState(
      key: key ?? this.key,
      rememberedForSession: rememberedForSession ?? this.rememberedForSession,
    );
  }
}

class ApiKeyController extends Notifier<ApiKeyState> {
  @override
  ApiKeyState build() {
    final remembered = SessionStorage.readApiKey();
    if (remembered != null && remembered.isNotEmpty) {
      return ApiKeyState(key: remembered, rememberedForSession: true);
    }
    return const ApiKeyState();
  }

  void setKey(String key, {required bool rememberForSession}) {
    final trimmed = key.trim();
    if (rememberForSession) {
      SessionStorage.writeApiKey(trimmed);
    } else {
      SessionStorage.clearApiKey();
    }
    state = ApiKeyState(key: trimmed, rememberedForSession: rememberForSession);
  }

  void forget() {
    SessionStorage.clearApiKey();
    state = const ApiKeyState();
  }
}

final apiKeyProvider = NotifierProvider<ApiKeyController, ApiKeyState>(
  ApiKeyController.new,
);

/// Set when Mistral rejects the current key. The unlock screen reads this
/// to show a clear "key was rejected" message.
final keyRejectedMessageProvider = StateProvider<String?>((ref) => null);
