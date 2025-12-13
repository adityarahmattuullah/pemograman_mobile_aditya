import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'utils/preference_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    isDark = await PreferenceHelper.loadTheme();
    setState(() {});
  }

  void _changeTheme(bool value) {
    setState(() => isDark = value);
    PreferenceHelper.saveTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? darkTheme : lightTheme,
      home: HomePage(
        isDark: isDark,
        onThemeChange: _changeTheme,
      ),
    );
  }
}

/* =======================
   🌞 LIGHT THEME
   ======================= */
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  scaffoldBackgroundColor: const Color(0xFFF4F6FA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo,
  ),
  cardTheme: const CardThemeData(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);

/* =======================
   🌙 DARK THEME
   ======================= */
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);
