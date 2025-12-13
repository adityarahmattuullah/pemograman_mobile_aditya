import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const MainNavigation({super.key, required this.onThemeChanged});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onThemeChanged: widget.onThemeChanged),
      ProfilePage(onThemeChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      body: pages[index],

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
