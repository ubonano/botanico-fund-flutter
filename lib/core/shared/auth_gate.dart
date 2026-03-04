import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:botanico_fund_flutter/core/config/locator.dart';
import 'package:botanico_fund_flutter/core/services/auth_service.dart';
import 'package:botanico_fund_flutter/core/services/user_role_service.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';
import 'package:botanico_fund_flutter/features/dashboard/screens/dashboard_screen.dart';
import 'package:botanico_fund_flutter/features/investor/screens/investor_home_screen.dart';
import 'package:botanico_fund_flutter/features/login/screens/login_screen.dart';

/// Widget que actúa como guardia de autenticación y autorización.
///
/// Escucha el estado de autenticación de Firebase Auth. Cuando el usuario
/// está autenticado, consulta su rol en la colección `users` de Firestore
/// y redirige a la pantalla correspondiente:
/// - `admin` → [DashboardScreen]
/// - `investor` → [InvestorHomeScreen]
/// - Rol desconocido → cierra sesión automáticamente
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
          return const _LoadingScreen();
        }

        // Si el usuario está autenticado, determinar su rol
        if (snapshot.hasData) {
          return _RoleRouter(uid: snapshot.data!.uid);
        }

        // Si no está autenticado, mostrar login
        return const LoginScreen();
      },
    );
  }
}

/// Widget que consulta el rol del usuario y redirige a la pantalla correcta.
class _RoleRouter extends StatelessWidget {
  final String uid;

  const _RoleRouter({required this.uid});

  @override
  Widget build(BuildContext context) {
    final roleService = locator<UserRoleService>();

    return FutureBuilder<String?>(
      future: roleService.getUserRole(uid),
      builder: (context, snapshot) {
        // Mientras se obtiene el rol, mostrar loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final role = snapshot.data;

        if (role == 'admin') {
          return const DashboardScreen();
        }

        if (role == 'investor') {
          return const InvestorHomeScreen();
        }

        // Rol desconocido o documento inexistente: cerrar sesión
        WidgetsBinding.instance.addPostFrameCallback((_) {
          locator<AuthService>().signOut();
        });

        return const _LoadingScreen();
      },
    );
  }
}

/// Pantalla de carga reutilizable con el estilo visual de la app.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF09090B),
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
