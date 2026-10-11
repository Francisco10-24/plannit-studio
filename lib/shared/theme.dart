import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta de docs/DESIGN.md
const Color kVino = Color(0xFF9B1B30); // único acento
const Color kTinta = Color(0xFF2B1216); // texto principal
const Color kMalva = Color(0xFF8A6E72); // texto secundario
const Color kFondo = Color(0xFFFBF4F1);
const Color kSuperficie = Color(0xFFFFFDFC);
const Color kBorde = Color(0xFFF0DEDA);
const Color kRosa = Color(0xFFF7DDE0);
const Color kError = Color(0xFFD9480F);
const Color kExito = Color(0xFF3F7D5A);
const Color kAviso = Color(0xFFC98A1B);

// Estilo de las franjas técnicas HTTP
TextStyle estiloMono({double size = 11, Color color = kTinta}) =>
    GoogleFonts.spaceMono(fontSize: size, color: color);

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kVino,
      primary: kVino,
      error: kError,
      surface: kSuperficie,
    ),
  );

  OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: ancho),
      );

  return base.copyWith(
    scaffoldBackgroundColor: kFondo,
    // Tipografía estilo Airbnb (Figtree)
    textTheme: GoogleFonts.figtreeTextTheme(base.textTheme)
        .apply(bodyColor: kTinta, displayColor: kTinta),
    appBarTheme: AppBarTheme(
      backgroundColor: kFondo,
      foregroundColor: kTinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.figtree(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: kTinta,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSuperficie,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: borde(kBorde, 1),
      focusedBorder: borde(kVino, 2),
      errorBorder: borde(kError, 2),
      focusedErrorBorder: borde(kError, 2),
      errorStyle: const TextStyle(color: kError),
      hintStyle: const TextStyle(color: kMalva),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kVino,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kBorde,
        disabledForegroundColor: kMalva,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kRosa,
      selectedColor: kVino,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: GoogleFonts.figtree(color: kTinta, fontWeight: FontWeight.w500),
      secondaryLabelStyle: GoogleFonts.figtree(color: Colors.white),
      checkmarkColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected) ? Colors.white : kMalva,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected) ? kVino : kBorde,
      ),
    ),
  );
}
