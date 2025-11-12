import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Fallback storage when plugins are unavailable (web/in-memory)
import 'favorites_storage_stub.dart'
    if (dart.library.html) 'favorites_storage_web.dart';
import '../models/chat_history.dart';

// Top-level parser for compute() (must be a top-level or static function)
List<ChatHistory> _parseHistory(String jsonString) {
  final List<dynamic> decoded = jsonDecode(jsonString);
  return decoded.map((item) => ChatHistory.fromJson(item)).toList();
}

class ChatHistoryService {
  static const String _historyKey = 'chat_history';
  static const int _maxHistory = 5;

  SharedPreferences? _prefs;
  List<ChatHistory>? _cache;

  Future<SharedPreferences> _prefsInstance() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<ChatHistory>> getHistory() async {
    // Return cache if available
    if (_cache != null) return _cache!;

    String? historyJson;
    try {
      final prefs = await _prefsInstance();
      historyJson = prefs.getString(_historyKey);
    } on MissingPluginException catch (_) {
      // Fallback to simple storage (web localStorage or in-memory stub)
      historyJson = FavoritesStorage().read(_historyKey);
    }

    if (historyJson == null) {
      _cache = [];
      return _cache!;
    }

    // Try to offload JSON parsing to a background isolate to avoid jank on the UI thread.
    // On some platforms (web) compute can fail or be unsupported; guard and fall back
    // to synchronous parsing to ensure the call always completes.
    try {
      final parsed = await compute(_parseHistory, historyJson);
      _cache = parsed;
      return _cache!;
    } catch (e) {
      try {
        // Fallback: parse on current thread
        final parsed = _parseHistory(historyJson);
        _cache = parsed;
        return _cache!;
      } catch (e2) {
        // If parsing also fails, return empty list to avoid indefinite loading in UI.
        _cache = [];
        return _cache!;
      }
    }
  }

  Future<void> saveChat({
    required String title,
    required List<String> messages,
  }) async {
    final history = await getHistory();

    final newChat = ChatHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      timestamp: DateTime.now(),
      messages: messages,
    );

    // Voeg toe aan begin
    history.insert(0, newChat);

    // Bewaar alleen laatste 5
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }

    // Update cache
    _cache = history;

    final String encoded = jsonEncode(history.map((h) => h.toJson()).toList());
    try {
      final prefs = await _prefsInstance();
      try {
        await prefs.setString(_historyKey, encoded);
        // ignore: avoid_print
        print(
          '[ChatHistoryService] saved history to SharedPreferences ($_historyKey)',
        );
      } on MissingPluginException catch (_) {
        FavoritesStorage().write(_historyKey, encoded);
        // ignore: avoid_print
        print(
          '[ChatHistoryService] SharedPreferences plugin missing, saved history to FavoritesStorage fallback',
        );
      }
    } on MissingPluginException catch (_) {
      // If getInstance fails, fall back to storage
      FavoritesStorage().write(_historyKey, encoded);
      // ignore: avoid_print
      print(
        '[ChatHistoryService] SharedPreferences.getInstance missing, saved history to FavoritesStorage fallback',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ChatHistoryService] Error saving history: $e');
      return;
    }
  }

  Future<void> deleteChat(String id) async {
    final history = await getHistory();
    history.removeWhere((chat) => chat.id == id);

    // Update cache
    _cache = history;

    final String encoded = jsonEncode(history.map((h) => h.toJson()).toList());
    try {
      final prefs = await _prefsInstance();
      try {
        await prefs.setString(_historyKey, encoded);
        // ignore: avoid_print
        print(
          '[ChatHistoryService] updated history in SharedPreferences ($_historyKey)',
        );
      } on MissingPluginException catch (_) {
        FavoritesStorage().write(_historyKey, encoded);
        // ignore: avoid_print
        print(
          '[ChatHistoryService] SharedPreferences missing, updated history in FavoritesStorage fallback',
        );
      }
    } on MissingPluginException catch (_) {
      FavoritesStorage().write(_historyKey, encoded);
      // ignore: avoid_print
      print(
        '[ChatHistoryService] SharedPreferences.getInstance missing, updated history in FavoritesStorage fallback',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ChatHistoryService] Error updating history: $e');
      return;
    }
  }

  Future<void> clearHistory() async {
    _cache = [];
    try {
      final prefs = await _prefsInstance();
      await prefs.remove(_historyKey);
    } on MissingPluginException catch (_) {
      FavoritesStorage().remove(_historyKey);
    }
  }
}
