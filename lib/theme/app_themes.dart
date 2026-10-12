import 'package:flutter/material.dart';

/// A selectable colour variation (works in both light and dark mode).
class AppPalette {
  final String id;
  final String name;
  final Color seed;

  const AppPalette(this.id, this.name, this.seed);
}

class AppThemes {
  static const List<AppPalette> palettes = [
    AppPalette('purple', 'Violet', Color(0xFF673AB7)),
    AppPalette('ocean', 'Ocean', Color(0xFF0277BD)),
    AppPalette('forest', 'Forest', Color(0xFF2E7D32)),
    AppPalette('rose', 'Rose', Color(0xFFC2185B)),
    AppPalette('amber', 'Amber', Color(0xFFEF6C00)),
  ];

  static AppPalette byId(String id) =>
      palettes.firstWhere((p) => p.id == id, orElse: () => palettes.first);

  /// Builds the theme for one palette. [highContrast] raises the contrast of
  /// the colours and uses pure black/white surfaces.
  static ThemeData build(
    AppPalette palette,
    Brightness brightness, {
    bool highContrast = false,
  }) {
    var scheme = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: brightness,
      contrastLevel: highContrast ? 1.0 : 0.0,
    );

    if (highContrast) {
      final dark = brightness == Brightness.dark;
      scheme = scheme.copyWith(
        surface: dark ? Colors.black : Colors.white,
        onSurface: dark ? Colors.white : Colors.black,
        onSurfaceVariant: dark ? Colors.white : Colors.black87,
        outline: dark ? Colors.white70 : Colors.black87,
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      dividerTheme: DividerThemeData(
        color: highContrast ? scheme.outline : null,
      ),
    );
  }
}
