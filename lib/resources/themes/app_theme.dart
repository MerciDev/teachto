import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LightTheme {
  ThemeData getThemeData() {
    return ThemeData(
      primaryColor: Colors.blue[300], // Color primario azul claro
      hintColor: Colors.blueAccent, // Color de acento azul
      scaffoldBackgroundColor:
          Colors.blueGrey[50], // Color de fondo del Scaffold
      // Otros aspectos del tema claro según sea necesario
    );
  }
}

class CustomThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue.shade300,
    hintColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.blue.shade50,
    appBarTheme: AppBarTheme(
      color: Colors.blue.shade300,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent, side: const BorderSide(color: Colors.blueAccent),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue.shade300,
    hintColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.blueGrey.shade900,
    appBarTheme: AppBarTheme(
      color: Colors.blueGrey.shade900,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent, side: const BorderSide(color: Colors.blueAccent),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
  );
}
