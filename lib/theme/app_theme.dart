import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // Color de fondo del campo de texto
      hintStyle: TextStyle(
        color: const Color.fromARGB(255, 0, 0, 0),
      ), // Color del texto de sugerencia
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.blueGrey, // Color del cursor
      selectionColor: Colors.grey, // Fondo de selección
      selectionHandleColor: Colors.grey, // Color de los handles
    ),
    cardColor: Colors.grey[900],
    iconTheme: const IconThemeData(color: Colors.white),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.white,
      secondary: Colors.grey,
    ),
    dialogTheme: DialogThemeData(backgroundColor: Colors.grey[850]),
  );
}
