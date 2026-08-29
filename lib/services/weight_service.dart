import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weight_entry.dart';

class WeightService extends ChangeNotifier {
  WeightService() {
    init();
  }

  static const _entriesKey = 'weightme_entries_v1';
  static const _profileKey = 'weightme_profile_v1';

  List<WeightEntry> _entries = [];
  UserProfile _profile = const UserProfile();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<WeightEntry> get entries => List.unmodifiable(_entries);
  UserProfile get profile => _profile;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJsonStr = prefs.getString(_profileKey);
    if (profileJsonStr != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(profileJsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }

    final entriesJsonStr = prefs.getString(_entriesKey);
    if (entriesJsonStr != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(entriesJsonStr) as List<dynamic>;
        _entries = jsonList
            .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    } else {
      // Cargar datos iniciales de demostración para el MVP
      _entries = _generateInitialEntries();
      await _saveEntries();
    }

    _sortEntriesAndCalculateDeltas();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addEntry({
    required double weightKg,
    required DateTime date,
    String? note,
  }) async {
    final newEntry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      weightKg: weightKg,
      note: note,
    );

    _entries.add(newEntry);
    _sortEntriesAndCalculateDeltas();
    await _saveEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    _sortEntriesAndCalculateDeltas();
    await _saveEntries();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  double get currentWeight {
    if (_entries.isEmpty) return _profile.startingWeight;
    return _entries.first.weightKg;
  }

  double get totalLost {
    final lost = _profile.startingWeight - currentWeight;
    return lost < 0 ? 0.0 : lost;
  }

  double get weeklyChange {
    if (_entries.length < 2) return 0.0;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    WeightEntry? oldestInWeek;
    for (final entry in _entries.reversed) {
      if (entry.date.isAfter(weekAgo) || entry.date.isAtSameMomentAs(weekAgo)) {
        oldestInWeek = entry;
        break;
      }
    }

    if (oldestInWeek == null) return 0.0;
    return currentWeight - oldestInWeek.weightKg;
  }

  double get progressPercentage {
    final totalToLose = _profile.startingWeight - _profile.targetWeight;
    if (totalToLose <= 0) return 1.0;
    final currentLost = _profile.startingWeight - currentWeight;
    final progress = currentLost / totalToLose;
    return progress.clamp(0.0, 1.0);
  }

  double get remainingKg {
    final remaining = currentWeight - _profile.targetWeight;
    return remaining < 0 ? 0.0 : remaining;
  }

  List<MonthEntries> get historyByMonth {
    final Map<String, List<WeightEntry>> grouped = {};

    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    for (final entry in _entries) {
      final monthName = '${months[entry.date.month - 1]} ${entry.date.year}';
      grouped.putIfAbsent(monthName, () => []).add(entry);
    }

    return grouped.entries
        .map((e) => MonthEntries(month: e.key, entries: e.value))
        .toList();
  }

  void _sortEntriesAndCalculateDeltas() {
    _entries.sort((a, b) => b.date.compareTo(a.date));

    for (var i = 0; i < _entries.length; i++) {
      if (i == _entries.length - 1) {
        _entries[i] = _entries[i].copyWith(delta: 0.0);
      } else {
        final previousWeight = _entries[i + 1].weightKg;
        final delta = _entries[i].weightKg - previousWeight;
        _entries[i] = _entries[i].copyWith(delta: double.parse(delta.toStringAsFixed(1)));
      }
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries.map((e) => e.toJson()).toList();
    await prefs.setString(_entriesKey, jsonEncode(jsonList));
  }

  static List<WeightEntry> _generateInitialEntries() {
    final now = DateTime.now();
    return [
      WeightEntry(
        id: '1',
        date: now.subtract(const Duration(hours: 2)),
        weightKg: 75.4,
        delta: -0.8,
        note: 'Desayuno ligero',
      ),
      WeightEntry(
        id: '2',
        date: now.subtract(const Duration(days: 7)),
        weightKg: 76.2,
        delta: -0.5,
      ),
      WeightEntry(
        id: '3',
        date: now.subtract(const Duration(days: 14)),
        weightKg: 76.7,
        delta: -0.9,
      ),
      WeightEntry(
        id: '4',
        date: now.subtract(const Duration(days: 21)),
        weightKg: 77.6,
        delta: -0.7,
      ),
      WeightEntry(
        id: '5',
        date: now.subtract(const Duration(days: 30)),
        weightKg: 78.3,
        delta: -1.2,
      ),
      WeightEntry(
        id: '6',
        date: now.subtract(const Duration(days: 60)),
        weightKg: 81.5,
        delta: -1.5,
      ),
      WeightEntry(
        id: '7',
        date: now.subtract(const Duration(days: 90)),
        weightKg: 85.2,
        delta: 0.0,
      ),
    ];
  }
}
