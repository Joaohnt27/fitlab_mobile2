import 'package:fitlab_mobile2/screens/feed_screen.dart';
import 'package:fitlab_mobile2/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import 'workouts_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Lista de telas
  final List<Widget> _screens = [
    const FeedScreen(),
    const WorkoutsScreen(),
    const Center(
      child: Text('Corrida (Play)', style: TextStyle(color: Colors.white)),
    ),
    const Center(
      child: Text('Comunidade', style: TextStyle(color: Colors.white)),
    ),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _screens[_selectedIndex],

      //botão central "Play" (Run)
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barra de Navegação
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1E1E),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Feed'),
              _buildNavItem(1, Icons.fitness_center_rounded, 'Treinos'),
              const SizedBox(width: 40), // Espaço para o botão central
              _buildNavItem(3, Icons.people_alt_rounded, 'Comunidade'),
              _buildNavItem(4, Icons.person_rounded, 'Você'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF06B6D4) : Colors.white54,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF06B6D4) : Colors.white54,
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
