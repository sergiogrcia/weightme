import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weight_entry.dart';
import 'database_service.dart';

class WeightService extends ChangeNotifier {
  WeightService() {
    init();
  }

  static const _legacyEntriesKey = 'weightme_entries_v1';
  static const _legacyProfileKey = 'weightme_profile_v1';

  final DatabaseService _db = DatabaseService();

  List<WeightEntry> _entries = [];
  UserProfile _profile = const UserProfile();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<WeightEntry> get entries => List.unmodifiable(_entries);
  UserProfile get profile => _profile;

  Future<void> init() async {
    final dbProfile = await _db.getProfile();
    final dbEntries = await _db.getEntries();

    if (dbProfile != null || dbEntries.isNotEmpty) {
      _profile = dbProfile ?? const UserProfile();
      _entries = dbEntries;
    } else {
      // Intentar migrar desde SharedPreferences legados si existen
      final prefs = await SharedPreferences.getInstance();
      final profileJsonStr = prefs.getString(_legacyProfileKey);
      final entriesJsonStr = prefs.getString(_legacyEntriesKey);

      if (profileJsonStr != null || entriesJsonStr != null) {
        if (profileJsonStr != null) {
          try {
            _profile = UserProfile.fromJson(jsonDecode(profileJsonStr) as Map<String, dynamic>);
          } catch (_) {}
        }
        if (entriesJsonStr != null) {
          try {
            final List<dynamic> jsonList = jsonDecode(entriesJsonStr) as List<dynamic>;
            _entries = jsonList
                .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (_) {}
        }
      } else {
        // Cargar datos iniciales de demostración
        _profile = const UserProfile();
        _entries = _generateInitialEntries();
      }

      // Guardar en la nueva base de datos SQLite
      await _db.saveProfile(_profile);
      await _db.insertEntries(_entries);

      // Limpiar SharedPreferences antiguos
      await prefs.remove(_legacyProfileKey);
      await prefs.remove(_legacyEntriesKey);
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
    await _db.insertEntry(newEntry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    _sortEntriesAndCalculateDeltas();
    await _db.deleteEntry(id);
    notifyListeners();
  }

  Future<void> restoreEntry(WeightEntry entry) async {
    _entries.add(entry);
    _sortEntriesAndCalculateDeltas();
    await _db.insertEntry(entry);
    notifyListeners();
  }

  Future<void> updateEntry({
    required String id,
    required double weightKg,
    DateTime? date,
    String? note,
  }) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      final updated = _entries[index].copyWith(
        weightKg: weightKg,
        date: date ?? _entries[index].date,
        note: note,
      );
      _entries[index] = updated;
      _sortEntriesAndCalculateDeltas();
      await _db.updateEntry(updated);
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await _db.saveProfile(_profile);
    notifyListeners();
  }

  // --- EXPORTAR E IMPORTAR COPIA DE SEGURIDAD (JSON) ---

  Future<String?> exportBackupFile() async {
    final backupMap = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profile.toJson(),
      'entries': _entries.map((e) => e.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupMap);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    final result = await FilePickerPlatform.instance.saveFile(
      dialogTitle: 'Guardar copia de seguridad',
      fileName: 'weightme_backup.json',
      mimeType: 'application/json',
      bytes: bytes,
    );

    return result?.toString();
  }

  Future<bool> importBackupFromFile() async {
    final files = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (files.isEmpty) {
      return false; // El usuario canceló la selección
    }

    final file = files.first;
    String content = '';

    if (file.path != null && file.path!.isNotEmpty) {
      content = await File(file.path!).readAsString();
    }

    if (content.isEmpty) return false;

    try {
      final dynamic decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) return false;

      final profileJson = decoded['profile'] as Map<String, dynamic>?;
      final entriesJson = decoded['entries'] as List<dynamic>?;

      if (profileJson == null || entriesJson == null) return false;

      final importedProfile = UserProfile.fromJson(profileJson);
      final importedEntries = entriesJson
          .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      await _db.replaceAllData(importedProfile, importedEntries);

      _profile = importedProfile;
      _entries = importedEntries;
      _sortEntriesAndCalculateDeltas();

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- MÉTODOS Y PROPIEDADES DE UNIDADES Y CÁLCULO ---

  static const double kgToLbsRatio = 2.20462262185;

  double displayWeight(double weightInKg) {
    if (_profile.unit == 'lbs') {
      return double.parse((weightInKg * kgToLbsRatio).toStringAsFixed(1));
    }
    return double.parse(weightInKg.toStringAsFixed(1));
  }

  double inputWeightToKg(double inputWeight) {
    if (_profile.unit == 'lbs') {
      return inputWeight / kgToLbsRatio;
    }
    return inputWeight;
  }

  double get currentWeight {
    if (_entries.isEmpty) return _profile.startingWeight;
    return _entries.first.weightKg;
  }

  double get currentDisplayWeight => displayWeight(currentWeight);

  double get totalLost {
    final lost = _profile.startingWeight - currentWeight;
    return lost < 0 ? 0.0 : lost;
  }

  double get totalLostDisplay => displayWeight(totalLost);

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

  double get weeklyChangeDisplay => displayWeight(weeklyChange);

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

  double get remainingDisplay => displayWeight(remainingKg);

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
