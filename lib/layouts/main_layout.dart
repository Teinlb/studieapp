import 'package:flutter/material.dart';
import 'package:studieapp/views/main/learning/learning_view.dart';
import 'package:studieapp/views/main/planning/planning_view.dart';
import 'package:studieapp/views/main/profile/profile_view.dart';

// Main layout widget die de basis navigatie bevat
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // De verschillende pagina's van je app
  final List<Widget> _pages = [
    const LearningView(),
    const PlanningView(),
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar die je voor elke pagina kunt aanpassen
      appBar: AppBar(
        title: _buildAppBarTitle(),
        centerTitle: true,
      ),
      // De body toont de huidige pagina
      body: _pages[_selectedIndex],
      // Bottom navigation bar voor de hoofdnavigatie
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Leren',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plannen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profiel',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper method om de juiste titel te tonen
  Widget _buildAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text('Leren');
      case 1:
        return const Text('Planning');
      case 2:
        return const Text('Mijn Profiel');
      default:
        return const Text('Studie App');
    }
  }
}

class PlannenPage extends StatefulWidget {
  const PlannenPage({super.key});

  @override
  State<PlannenPage> createState() => _PlannenPageState();
}

class _PlannenPageState extends State<PlannenPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Plannen Content'),
    );
  }
}

class ProfielPage extends StatelessWidget {
  const ProfielPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profiel Content'),
    );
  }
}
