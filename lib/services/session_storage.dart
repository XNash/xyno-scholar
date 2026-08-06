import 'package:web/web.dart' as web;

/// Thin wrapper around browser `sessionStorage`. Used only for the optional
/// "remember for this browser session" convenience toggle — never for
/// permanent (localStorage) persistence of the API key.
class SessionStorage {
  static const _apiKeyStorageKey = 'xyno_scholar_api_key';

  static void writeApiKey(String key) {
    web.window.sessionStorage.setItem(_apiKeyStorageKey, key);
  }

  static String? readApiKey() {
    return web.window.sessionStorage.getItem(_apiKeyStorageKey);
  }

  static void clearApiKey() {
    web.window.sessionStorage.removeItem(_apiKeyStorageKey);
  }
}
