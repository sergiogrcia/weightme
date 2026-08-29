class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.note,
    this.delta = 0.0,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final String? note;
  final double delta; // positivo = subió, negativo = bajó, 0 = igual

  int get day => date.day;
  String get time {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = date.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'note': note,
        'delta': delta,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num).toDouble(),
        note: json['note'] as String?,
        delta: (json['delta'] as num?)?.toDouble() ?? 0.0,
      );

  WeightEntry copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? note,
    double? delta,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
      delta: delta ?? this.delta,
    );
  }
}

class MonthEntries {
  const MonthEntries({required this.month, required this.entries});

  final String month;
  final List<WeightEntry> entries;
}

class UserProfile {
  const UserProfile({
    this.name = 'Alex Mercer',
    this.startingWeight = 85.2,
    this.targetWeight = 75.0,
    this.unit = 'kg',
    this.dailyReminders = true,
  });

  final String name;
  final double startingWeight;
  final double targetWeight;
  final String unit;
  final bool dailyReminders;

  Map<String, dynamic> toJson() => {
        'name': name,
        'startingWeight': startingWeight,
        'targetWeight': targetWeight,
        'unit': unit,
        'dailyReminders': dailyReminders,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'Alex Mercer',
        startingWeight: (json['startingWeight'] as num?)?.toDouble() ?? 85.2,
        targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 75.0,
        unit: json['unit'] as String? ?? 'kg',
        dailyReminders: json['dailyReminders'] as bool? ?? true,
      );

  UserProfile copyWith({
    String? name,
    double? startingWeight,
    double? targetWeight,
    String? unit,
    bool? dailyReminders,
  }) {
    return UserProfile(
      name: name ?? this.name,
      startingWeight: startingWeight ?? this.startingWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      unit: unit ?? this.unit,
      dailyReminders: dailyReminders ?? this.dailyReminders,
    );
  }
}