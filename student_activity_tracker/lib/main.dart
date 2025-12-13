import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation.dart';

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
    loadTheme();
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => isDark = prefs.getBool("darkMode") ?? false);
  }

  Future<void> saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("darkMode", value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Activity Tracker",
      debugShowCheckedModeBanner: false,

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),

      home: MainNavigation(
        onThemeChanged: (value) {
          setState(() => isDark = value);
          saveTheme(value);
        },
      ),
    );
  }
}
