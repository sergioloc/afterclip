enum EnergySavingMode {
  off,
  on;

  String get label => switch (this) {
        EnergySavingMode.off => 'Desactivado',
        EnergySavingMode.on => 'Activado',
      };
}