import 'package:fitlab_mobile2/screens/community_screen.dart';
import 'package:fitlab_mobile2/screens/feed_screen.dart';
import 'package:fitlab_mobile2/screens/profile_screen.dart';
import 'package:fitlab_mobile2/screens/run_screen.dart';
import 'package:flutter/material.dart';
import 'workouts_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const WorkoutsScreen(),
    const RunScreen(),
    const CommunityScreen(),
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

      bottomNavigationBar: Container(
        color: const Color(0xFF1E1E1E),
        height: 90,
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Feed'),
            _buildNavItem(1, Icons.fitness_center_rounded, 'Laboratório'),
            _buildNavItem(2, Icons.play_arrow_rounded, 'Iniciar'),
            _buildNavItem(3, Icons.people_alt_rounded, 'Comunidade'),
            _buildNavItem(4, Icons.person_rounded, 'Você'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool active = _selectedIndex == index;
    bool isActionBtn = index == 2;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isActionBtn)
            // BOTÃO DE AÇÃO DESTAQUE (CÍRCULO AZUL)
            Container(
              padding: const EdgeInsets.all(10), // Espaço em volta do ícone
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: active
                      ? [const Color(0xFF06B6D4), const Color(0xFF0891B2)]
                      : [
                          const Color(0xFF06B6D4).withOpacity(0.1),
                          const Color(0xFF06B6D4).withOpacity(0.05),
                        ],
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: active
                      ? Colors.white24
                      : const Color(0xFF06B6D4).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: active ? Colors.black : const Color(0xFF06B6D4),
                size: 24,
              ),
            )
          else
            // ITENS NORMAIS
            Icon(
              icon,
              color: active ? const Color(0xFF06B6D4) : Colors.white54,
              size: 26,
            ),

          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF06B6D4) : Colors.white54,
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              letterSpacing: isActionBtn ? 0.5 : 0,
            ),
          ),
        ],
      ),
    );
  }
}
