import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const ProfilePage({super.key, required this.onThemeChanged});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<Offset> slideIn;

  @override
  void initState() {
    super.initState();

    // ANIMASI
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    slideIn = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),

      body: FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(
          position: slideIn,

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // FOTO PROFIL DENGAN HERO ANIMATION
                Hero(
                  tag: "profile-photo",
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage("assets/images/profil.jpg"),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  child: const Text("Pengguna Aplikasi"),
                ),

                const Text(
                  "Student Activity Tracker",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // KARTU INFORMASI DENGAN ANIMASI
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue),
                          SizedBox(width: 10),
                          Text("aditrahmttullah33@gmail.com", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.green),
                          SizedBox(width: 10),
                          Text("0813-7778-6704", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // DARK MODE SWITCH
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: widget.onThemeChanged,
                  secondary: const Icon(Icons.dark_mode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
