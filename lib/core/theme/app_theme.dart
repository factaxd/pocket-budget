import 'package:flutter/material.dart';

import 'package:pocket_budget/core/theme/cuzdan_colors.dart';

abstract final class AppTheme {
  static const fontFamily = 'Plus Jakarta Sans';

  static ThemeData light() => _build(_lightScheme, CuzdanColors.light);

  static ThemeData dark() => _build(_darkScheme, CuzdanColors.dark);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF7E4A72),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEDE3EB),
    onPrimaryContainer: Color(0xFF34202F),
    secondary: Color(0xFF4F7D5F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCEBDF),
    onSecondaryContainer: Color(0xFF1F3A28),
    error: Color(0xFFB3263E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F4F6),
    onSurface: Color(0xFF241C24),
    onSurfaceVariant: Color(0xFF6B6170),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF0EDF0),
    surfaceContainer: Color(0xFFEBE7EB),
    surfaceContainerHigh: Color(0xFFE6E1E6),
    surfaceContainerHighest: Color(0xFFE0DAE0),
    outline: Color(0xFFC9C0C9),
    outlineVariant: Color(0xFFE3DDE3),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD6B0CC),
    onPrimary: Color(0xFF3A2135),
    primaryContainer: Color(0xFF4E3248),
    onPrimaryContainer: Color(0xFFF3E6EF),
    secondary: Color(0xFF9CC5A8),
    onSecondary: Color(0xFF16301F),
    secondaryContainer: Color(0xFF2E4A37),
    onSecondaryContainer: Color(0xFFD5EADB),
    error: Color(0xFFFF8A9B),
    onError: Color(0xFF4A0C18),
    surface: Color(0xFF161317),
    onSurface: Color(0xFFECE6EC),
    onSurfaceVariant: Color(0xFFB1A6B1),
    surfaceContainerLowest: Color(0xFF201C21),
    surfaceContainerLow: Color(0xFF241F25),
    surfaceContainer: Color(0xFF2A252B),
    surfaceContainerHigh: Color(0xFF332D34),
    surfaceContainerHighest: Color(0xFF3C353D),
    outline: Color(0xFF6A606B),
    outlineVariant: Color(0xFF3A333B),
  );

  static ThemeData _build(ColorScheme scheme, CuzdanColors colors) {
    final base = ThemeData(colorScheme: scheme, fontFamily: fontFamily);
    final text = base.textTheme;
    TextStyle? heading(TextStyle? style) =>
        style?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5);

    final textTheme = text.copyWith(
      displaySmall: heading(text.displaySmall),
      headlineMedium: heading(text.headlineMedium),
      headlineSmall: heading(text.headlineSmall),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    final fieldShape = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: fieldShape,
        // A visible outline gives the floating label a border to sit on.
        enabledBorder: fieldShape.copyWith(borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: fieldShape.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: fieldShape.copyWith(borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: fieldShape.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        extendedTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    );
  }
}
