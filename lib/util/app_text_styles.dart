import 'package:flutter/material.dart';

abstract final class AppTextSizes {
  static const double counter = 96;
  static const double display = 30;
  static const double heading = 22;
  static const double titleLarge = 18;
  static const double titleMedium = 16;
  static const double titleSmall = 15;
  static const double bodyLarge = 14;
  static const double bodySmall = 13;
  static const double labelMedium = 12;
}

abstract final class AppTextStyles {

  static const TextStyle counter = TextStyle(
    fontSize: AppTextSizes.counter,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle display = TextStyle(
    fontSize: AppTextSizes.display,
    letterSpacing: 8,
  );

  static const TextStyle brandTitle = TextStyle(
    fontSize: AppTextSizes.titleLarge,
    fontWeight: FontWeight.w900,
    letterSpacing: 8,
  );

  static const TextStyle heading = TextStyle(
    fontSize: AppTextSizes.heading,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle itemTitle = TextStyle(
    fontSize: AppTextSizes.titleLarge,
  );

  static const TextStyle title = TextStyle(
    fontSize: AppTextSizes.titleMedium,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle input = TextStyle(
    fontSize: AppTextSizes.titleMedium,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: AppTextSizes.titleSmall,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppTextSizes.titleSmall,
  );

  static const TextStyle paragraph = TextStyle(
    fontSize: AppTextSizes.bodyLarge,
  );

  static const TextStyle metric = TextStyle(
    fontSize: AppTextSizes.bodyLarge,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppTextSizes.bodySmall,
  );

  static const TextStyle label = TextStyle(
    fontSize: AppTextSizes.bodySmall,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const TextStyle badge = TextStyle(
    fontSize: AppTextSizes.labelMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
}