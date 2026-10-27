import 'package:flutter/widgets.dart';

/// What expense and income categories share, so the same widgets can draw both.
abstract interface class EntryCategory {
  IconData get icon;

  /// Base hue of the category; see `EntryCategoryStyle` for theme-aware shades.
  Color get color;
}
