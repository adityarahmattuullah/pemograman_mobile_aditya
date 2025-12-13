import 'package:flutter/material.dart';
import '../screens/form_mahasiswa_screen.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form Mahasiswa',
      theme: appTheme,
      home: const FormMahasiswaScreen(),
    );
  }
}
