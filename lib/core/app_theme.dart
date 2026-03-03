import 'package:flutter/material.dart';

// ─── Brand Palette ───────────────────────────────────────────────────────────
class AppColors {
  // Emerald
  static const primary = Color(0xFF059669);
  static const primaryLight = Color(0xFF10B981);
  static const primaryDark = Color(0xFF047857);
  static const primarySurface = Color(0xFFECFDF5);
  static const primarySurfaceDeep = Color(0xFFD1FAE5);

  // Semantic
  static const danger = Color(0xFFDC2626);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const warning = Color(0xFFD97706);
  static const warningSurface = Color(0xFFFFFBEB);
  static const info = Color(0xFF2563EB);
  static const infoSurface = Color(0xFFEFF6FF);
  static const purple = Color(0xFF7C3AED);
  static const purpleSurface = Color(0xFFF3E8FF);

  // Neutrals
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  // Gradients
  static const gradientStart = Color(0xFF059669);
  static const gradientEnd = Color(0xFF0D9488); // teal-600

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroBg = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF134E4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x06000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 40, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> nav = [
    BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, -4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, -1)),
  ];
}

// ─── Radii ───────────────────────────────────────────────────────────────────
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 100;
}

// ─── Typography ──────────────────────────────────────────────────────────────
class AppText {
  static const TextStyle h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, height: 1.2, letterSpacing: -0.5,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3, letterSpacing: -0.3,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.6,
  );
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textMuted, height: 1.4,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textMuted, letterSpacing: 0.5,
  );
}

// ─── Theme Builder ────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: AppText.h3,
          iconTheme: IconThemeData(color: AppColors.textSecondary, size: 22),
        ),

        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          labelStyle: const TextStyle(
              color: AppColors.textMuted, fontSize: 14),
          hintStyle: const TextStyle(
              color: AppColors.textMuted, fontSize: 14),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                letterSpacing: 0.2),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.borderLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          labelStyle: AppText.caption,
        ),
      );
}
