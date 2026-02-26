import 'package:flutter/material.dart';
import 'overview_view.dart';
import 'investors_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [OverviewView(), InvestorsView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        title: const Text('Botanico Fund Dashboard', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
      ),
      body: Row(
        children: [
          // Sidebar Menu (Minimalist)
          NavigationRail(
            backgroundColor: const Color(0xFF1E293B), // Slate 800
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            unselectedIconTheme: const IconThemeData(color: Colors.white54),
            selectedIconTheme: const IconThemeData(color: Color(0xFF10B981)), // Emerald 500
            unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group),
                label: Text('Investors'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF334155)), // Slate 700
          // Main Content Area
          Expanded(child: _views[_selectedIndex]),
        ],
      ),
    );
  }
}
