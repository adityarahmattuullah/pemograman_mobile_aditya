import 'package:flutter/material.dart';
import 'screens/form_mahasiswa_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form Mahasiswa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FormMahasiswaScreen(),
    );
  }
}
