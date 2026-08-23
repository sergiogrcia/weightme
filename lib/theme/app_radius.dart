import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const Radius small = Radius.circular(4);
  static const Radius medium = Radius.circular(12);
  static const Radius large = Radius.circular(16);
  static const Radius extraLarge = Radius.circular(24);

  static const BorderRadius card = BorderRadius.all(large);
  static const BorderRadius input = BorderRadius.all(large);
  static const BorderRadius modal = BorderRadius.all(extraLarge);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(9999));
}
