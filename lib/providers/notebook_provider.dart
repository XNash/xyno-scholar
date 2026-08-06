import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/narrow_topic.dart';
import '../models/notebook_entry.dart';

const _notebookStorageKey = 'xyno_scholar_notebook_v1';
const _uuid = Uuid();

class NotebookController extends AsyncNotifier<List<NotebookEntry>> {
  @override
  Future<List<NotebookEntry>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notebookStorageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => NotebookEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persist(List<NotebookEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notebookStorageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> save(NarrowTopic topic) async {
    final current = state.value ?? [];
    final entry = NotebookEntry(
      id: _uuid.v4(),
      topic: topic,
      personalNotes: '',
      savedAt: DateTime.now(),
    );
    final updated = [entry, ...current];
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> remove(String id) async {
    final current = state.value ?? [];
    final updated = current.where((e) => e.id != id).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> updateNotes(String id, String notes) async {
    final current = state.value ?? [];
    final updated = [
      for (final e in current)
        if (e.id == id) e.copyWith(personalNotes: notes) else e,
    ];
    state = AsyncData(updated);
    await _persist(updated);
  }
}

final notebookProvider =
    AsyncNotifierProvider<NotebookController, List<NotebookEntry>>(
      NotebookController.new,
    );
