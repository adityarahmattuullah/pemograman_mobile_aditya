import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

// --- 1. GLOBAL NOTIFIER UNTUK TEMA ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  // Cek Status Login
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  // Cek Pilihan Tema Terakhir (Default: Terang)
  final bool isDark = prefs.getBool('isDark') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(LaundryApp(
    startPage: isLoggedIn ? const MainNavigation() : const LoginPage(),
  ));
}

class LaundryApp extends StatelessWidget {
  final Widget startPage;
  const LaundryApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    // --- 2. WRAP DENGAN VALUELISTENABLEBUILDER ---
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GO-CLEAN',
          
          // --- KONFIGURASI TEMA TERANG (INDIGO PREMIUM) ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E1B4B),
              primary: const Color(0xFF4338CA),
              surface: const Color(0xFFF8FAFC),
            ),
            scaffoldBackgroundColor: const Color(0xFFF1F5F9),
            cardColor: Colors.white,
          ),

          // --- KONFIGURASI TEMA GELAP (INDIGO DARK) ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E1B4B),
              brightness: Brightness.dark,
              primary: const Color(0xFF818CF8), // Indigo lebih terang untuk Dark Mode
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate Dark
            cardColor: const Color(0xFF1E293B),
          ),

          // Mengikuti Notifier
          themeMode: currentMode, 
          
          home: startPage,
        );
      },
    );
  }
}