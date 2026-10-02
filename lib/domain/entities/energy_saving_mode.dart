enum EnergySavingMode {
  off,
  on;

  String get label => switch (this) {
        EnergySavingMode.off => 'Off',
        EnergySavingMode.on => 'On',
      };
}
