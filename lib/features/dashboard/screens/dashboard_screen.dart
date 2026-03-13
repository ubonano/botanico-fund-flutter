import 'package:flutter/material.dart';
import 'package:botanico_fund_flutter/core/config/locator.dart';
import 'package:botanico_fund_flutter/core/services/auth_service.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';
import 'overview_view.dart';
import 'investors_screen.dart';
import 'bot_dashboard_view.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [OverviewView(), InvestorsScreen(), BotDashboardView(), SettingsScreen()];

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF27272A)),
        ),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text('Se cerrará tu sesión actual.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await locator<AuthService>().signOut();
    }
  }

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
              iconTheme: const IconThemeData(color: AppColors.primary), // Gold
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(50)),
                child: Image.asset('assets/images/botanico_logo_text.png', height: 28, fit: BoxFit.contain),
              ),
            ),
      drawer: isDesktop ? null : Drawer(backgroundColor: const Color(0xFF18181B), child: _buildSidebarContent()),
      body: Row(
        children: [
          // Sidebar fijo solo en Desktop
          if (isDesktop)
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: Color(0xFF18181B), // Zinc 900
                border: Border(
                  right: BorderSide(color: Color(0xFF27272A), width: 1), // Zinc 800
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
          padding: const EdgeInsets.only(top: 48.0, left: 24.0, right: 24.0, bottom: 40.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(50)),
            child: Image.asset('assets/images/botanico_logo_text.png', height: 100, fit: BoxFit.contain),
          ),
        ),

        // Menu Items
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MENU PRINCIPAL',
              style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildNavItem(index: 0, icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Resumen'),
        _buildNavItem(index: 1, icon: Icons.people_outlined, selectedIcon: Icons.people, label: 'Inversores'),
        _buildNavItem(index: 2, icon: Icons.smart_toy_outlined, selectedIcon: Icons.smart_toy, label: 'Bot'),
        const Spacer(),

        // Configuración
        _buildNavItem(index: 3, icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Configuración'),
        const SizedBox(height: 8),

        // Cerrar Sesión
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleLogout(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white38, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
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
    final color = isSelected ? AppColors.primary : Colors.white60;

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
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
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
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
