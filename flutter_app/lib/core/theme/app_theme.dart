import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ──
  static const Color primaryColor = Color(0xFF1A56DB);  // DisasterAid Blue
  static const Color primaryLight = Color(0xFF4B7FF5);
  static const Color primaryDark  = Color(0xFF0E3DB3);
  static const Color accentColor  = Color(0xFF0D9488);  // Teal (goods/inkind)
  static const Color accentLight  = Color(0xFF2DD4BF);

  static const Color errorColor   = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor    = Color(0xFF3B82F6);

  // ── Surface Colors ──
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor        = Colors.white;
  static const Color textPrimary      = Color(0xFF1A202C);
  static const Color textSecondary    = Color(0xFF4A5568);
  static const Color textDisabled     = Color(0xFFA0AEC0);
  static const Color borderSubtle     = Color(0xFFE2E8F0);
  static const Color borderLight      = Color(0xFFF7FAFC);

  // ── Urgency Colors ──
  static const Color urgencyCritical = Color(0xFFE53E3E);
  static const Color urgencyHigh     = Color(0xFFED8936);
  static const Color urgencyMedium   = Color(0xFFECC94B);
  static const Color urgencyLow      = Color(0xFF2DD4BF);

  // ── Status Colors ──
  static const Color statusPending    = Color(0xFFF59E0B);
  static const Color statusActive     = Color(0xFF10B981);
  static const Color statusInProgress = Color(0xFF7C3AED);
  static const Color statusVerified   = Color(0xFF10B981);
  static const Color statusFailed     = Color(0xFFE53E3E);
  static const Color statusNeutral    = Color(0xFF718096);
  static const Color statusAction     = Color(0xFF1A56DB);

  // ── Shared Input Decoration ──
  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(color: Color(0xFF718096)),
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color primary) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(Color primary) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Color primary) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.4)),
      ),
    );
  }

  // ── Light Theme ──
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      error: errorColor,
      surface: cardColor,
      onSurface: textPrimary,
      surfaceContainerHighest: const Color(0xFFEEF2F7),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: backgroundColor,

      // ── Typography ──
      textTheme: const TextTheme(
        headlineLarge:  TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: textPrimary),
        headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge:     TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        titleSmall:     TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
        bodyLarge:      TextStyle(fontSize: 15, height: 1.5, color: textSecondary),
        bodyMedium:     TextStyle(fontSize: 13, height: 1.4, color: textSecondary),
        bodySmall:      TextStyle(fontSize: 11, height: 1.4, color: textDisabled),
        labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelSmall:     TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textDisabled, letterSpacing: 0.5),
      ),

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 22),
        actionsIconTheme: IconThemeData(color: Colors.white, size: 22),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.06),
      ),

      // ── Buttons ──
      elevatedButtonTheme: _elevatedButtonTheme(primaryColor),
      filledButtonTheme:   _filledButtonTheme(primaryColor),
      outlinedButtonTheme: _outlinedButtonTheme(primaryColor),

      // ── Inputs ──
      inputDecorationTheme: _inputDecorationTheme(colorScheme),

      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEF2F7),
        selectedColor: primaryColor.withValues(alpha: 0.12),
        checkmarkColor: primaryColor,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDF2F7),
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ──
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 8,
      ),

      // ── NavigationBar ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryColor.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primaryColor : textDisabled,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primaryColor : textDisabled,
            size: 22,
          );
        }),
      ),

      // ── ProgressIndicator ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFEEF2F7),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2D3748),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  // ── Dark Theme ──
  static ThemeData get darkTheme {
    const darkSurface   = Color(0xFF1A1D2E);
    const darkBg        = Color(0xFF12141F);
    const darkCard      = Color(0xFF1E2235);
    const darkPrimary   = Color(0xFF4B7FF5);
    const darkSecondary = Color(0xFF2DD4BF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: Colors.white,
      secondary: darkSecondary,
      surface: darkSurface,
      onSurface: const Color(0xFFE2E8F0),
      surfaceContainerHighest: const Color(0xFF252840),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D3748), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: darkCard,
        foregroundColor: Color(0xFFE2E8F0),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE2E8F0),
        ),
        iconTheme: IconThemeData(color: Color(0xFFE2E8F0), size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252840),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3748)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3748)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: darkPrimary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? darkPrimary : const Color(0xFF718096),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? darkPrimary : const Color(0xFF718096),
            size: 22,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
