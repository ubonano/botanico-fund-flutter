import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:botanico_fund_flutter/core/config/locator.dart';
import 'package:botanico_fund_flutter/core/services/auth_service.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';
import 'package:botanico_fund_flutter/features/dashboard/screens/dashboard_screen.dart';
import 'package:botanico_fund_flutter/features/login/screens/login_screen.dart';

/// Widget que actúa como guardia de autenticación.
///
/// Escucha el estado de autenticación de Firebase Auth y redirige
/// al usuario a [LoginScreen] o [DashboardScreen] según corresponda.
/// Esto garantiza que ninguna pantalla sea accesible sin autenticación.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Mientras se determina el estado de auth, mostrar loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF09090B),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // Si el usuario está autenticado, mostrar el dashboard
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // Si no está autenticado, mostrar login
        return const LoginScreen();
      },
    );
  }
}
