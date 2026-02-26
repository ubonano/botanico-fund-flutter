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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Zinc 950
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF18181B), // Zinc 900
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)), // Gold
              title: const Text(
                'Botánico Fund',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: const Color(0xFF18181B),
              child: _buildSidebarContent(),
            ),
      body: Row(
        children: [
          // Sidebar fijo solo en Desktop
          if (isDesktop)
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: Color(0xFF18181B), // Zinc 900
                border: Border(
                  right: BorderSide(
                    color: Color(0xFF27272A),
                    width: 1,
                  ), // Zinc 800
                ),
              ),
              child: _buildSidebarContent(),
            ),

          // Main Content Area
          Expanded(
            child: Container(
              color: const Color(0xFF09090B), // Zinc 950
              child: _views[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        // Logo Area
        Padding(
          padding: const EdgeInsets.only(
            top: 48.0,
            left: 24.0,
            right: 24.0,
            bottom: 40.0,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFD4AF37,
                  ).withOpacity(0.1), // Corrected from .withValues(alpha: 0.1)
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ), // Corrected from .withValues(alpha: 0.3)
                ),
                child: const Icon(
                  Icons.spa,
                  color: Color(0xFFD4AF37),
                  size: 28,
                ), // Botánico icon in Gold
              ),
              const SizedBox(width: 16),
              const Text(
                'Botánico\nFund',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        // Menu Items
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MENU PRINCIPAL',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildNavItem(
          index: 0,
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Resumen',
        ),
        const SizedBox(height: 8),
        _buildNavItem(
          index: 1,
          icon: Icons.group_outlined,
          selectedIcon: Icons.group,
          label: 'Inversores',
        ),
        const Spacer(),

        // Bottom Area (e.g. Settings / Info)
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white38, size: 16),
              SizedBox(width: 8),
              Text(
                'v1.0.0',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? const Color(0xFFD4AF37)
        : Colors.white60; // Gold or default

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          // Si está en mobile y abre desde Drawer, lo cerramos al presionar
          final screenWidth = MediaQuery.of(context).size.width;
          if (screenWidth <= 800) {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4AF37).withOpacity(0.1)
                : Colors.transparent, // Corrected from .withValues(alpha: 0.1)
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4AF37).withOpacity(0.3)
                  : Colors
                        .transparent, // Corrected from .withValues(alpha: 0.3)
            ),
          ),
          child: Row(
            children: [
              Icon(isSelected ? selectedIcon : icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFD4AF37),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
