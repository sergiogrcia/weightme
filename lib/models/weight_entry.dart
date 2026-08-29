class WeightEntry {
  const WeightEntry({
    required this.day,
    required this.weightKg,
    required this.time,
    required this.delta,
  });

  final int day;
  final double weightKg;
  final String time;
  final double delta; // positivo = subió, negativo = bajó, 0 = igual
}

class MonthEntries {
  const MonthEntries({required this.month, required this.entries});

  final String month;
  final List<WeightEntry> entries;
}