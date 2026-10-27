import 'package:flutter/material.dart';

/// Colors outside the Material color scheme, used by the balance card and status text.
@immutable
class CuzdanColors extends ThemeExtension<CuzdanColors> {
  const CuzdanColors({
    required this.heroBackground,
    required this.heroForeground,
    required this.heroMuted,
    required this.heroTrack,
    required this.heroFill,
    required this.heroNegative,
    required this.heroPositive,
    required this.positive,
  });

  static const light = CuzdanColors(
    heroBackground: Color(0xFF3B1F3D),
    heroForeground: Color(0xFFFBF4EC),
    heroMuted: Color(0xFFC4B4C2),
    heroTrack: Color(0xFF553753),
    heroFill: Color(0xFFE7C68B),
    heroNegative: Color(0xFFFF9AA2),
    heroPositive: Color(0xFF9EE0B0),
    positive: Color(0xFF4F7D5F),
  );

  static const dark = CuzdanColors(
    heroBackground: Color(0xFF3A2438),
    heroForeground: Color(0xFFFBF4EC),
    heroMuted: Color(0xFFC4B4C2),
    heroTrack: Color(0xFF55394F),
    heroFill: Color(0xFFE7C68B),
    heroNegative: Color(0xFFFF9AA2),
    heroPositive: Color(0xFF9EE0B0),
    positive: Color(0xFF9CC5A8),
  );

  final Color heroBackground;
  final Color heroForeground;
  final Color heroMuted;
  final Color heroTrack;
  final Color heroFill;
  final Color heroNegative;

  /// Extra income on the balance card.
  final Color heroPositive;
  final Color positive;

  @override
  CuzdanColors copyWith({
    Color? heroBackground,
    Color? heroForeground,
    Color? heroMuted,
    Color? heroTrack,
    Color? heroFill,
    Color? heroNegative,
    Color? heroPositive,
    Color? positive,
  }) {
    return CuzdanColors(
      heroBackground: heroBackground ?? this.heroBackground,
      heroForeground: heroForeground ?? this.heroForeground,
      heroMuted: heroMuted ?? this.heroMuted,
      heroTrack: heroTrack ?? this.heroTrack,
      heroFill: heroFill ?? this.heroFill,
      heroNegative: heroNegative ?? this.heroNegative,
      heroPositive: heroPositive ?? this.heroPositive,
      positive: positive ?? this.positive,
    );
  }

  @override
  CuzdanColors lerp(CuzdanColors? other, double t) {
    if (other == null) return this;
    return CuzdanColors(
      heroBackground: Color.lerp(heroBackground, other.heroBackground, t)!,
      heroForeground: Color.lerp(heroForeground, other.heroForeground, t)!,
      heroMuted: Color.lerp(heroMuted, other.heroMuted, t)!,
      heroTrack: Color.lerp(heroTrack, other.heroTrack, t)!,
      heroFill: Color.lerp(heroFill, other.heroFill, t)!,
      heroNegative: Color.lerp(heroNegative, other.heroNegative, t)!,
      heroPositive: Color.lerp(heroPositive, other.heroPositive, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
    );
  }
}

extension CuzdanColorsContext on BuildContext {
  CuzdanColors get cuzdanColors => Theme.of(this).extension<CuzdanColors>()!;
}
