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

  String get dateFormatted {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hoy';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Ayer';
    }
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
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
    this.name = 'Anónimo',
    this.startingWeight = 0.0,
    this.targetWeight = 0.0,
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
        name: json['name'] as String? ?? 'Anónimo',
        startingWeight: (json['startingWeight'] as num?)?.toDouble() ?? 0.0,
        targetWeight: (json['targetWeight'] as num?)?.toDouble() ?? 0.0,
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