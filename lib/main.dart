import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelNotebookApp());
}

class TravelNotebookApp extends StatelessWidget {
  const TravelNotebookApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sổ tay Địa điểm Du lịch',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF0F8FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF009E9A),
        primary: const Color(0xFF008F8C),
        secondary: const Color(0xFFFFB74D),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE0F4F3),
        foregroundColor: Color(0xFF145A60),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF145A60),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: const Color(0x22008783),
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00A99D),
        foregroundColor: Colors.white,
        elevation: 5,
      ),
    ),
    home: const HomeScreen(),
  );
}
