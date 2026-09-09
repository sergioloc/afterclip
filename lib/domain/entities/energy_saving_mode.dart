enum EnergySavingMode {
  low,
  medium,
  high;

  String get label => switch (this) {
        EnergySavingMode.low => 'Bajo',
        EnergySavingMode.medium => 'Medio',
        EnergySavingMode.high => 'Alto',
      };
}