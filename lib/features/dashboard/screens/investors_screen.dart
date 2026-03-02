import 'package:flutter/material.dart';
import '../../../core/config/locator.dart';
import '../../../core/models/investor.dart';
import '../../../core/services/fund_repository.dart';
import '../../../core/theme/app_colors.dart';
import 'create_investor_dialog.dart';

class InvestorsScreen extends StatelessWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = locator<FundRepository>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.people_rounded, color: AppColors.primaryGold, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inversores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text('Gestión de personas registradas', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
              _buildAddButton(context),
            ],
          ),
          const SizedBox(height: 24),

          // List
          Expanded(
            child: StreamBuilder<List<Investor>>(
              stream: repository.streamInvestors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar inversores',
                      style: TextStyle(color: AppColors.error.withValues(alpha: 0.8), fontSize: 14),
                    ),
                  );
                }

                final investors = snapshot.data ?? [];

                if (investors.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  itemCount: investors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildInvestorTile(investors[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => CreateInvestorDialog.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryGold, size: 18),
            SizedBox(width: 8),
            Text(
              'Nuevo Inversor',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, color: Colors.white.withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 16),
          Text(
            'No hay inversores registrados',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Creá el primer inversor con el botón de arriba',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorTile(Investor investor) {
    final fullName = '${investor.name} ${investor.lastName}'.trim();
    final initials = _getInitials(investor.name, investor.lastName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(color: AppColors.primaryGold, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : investor.id,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                if (investor.email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(investor.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                ],
              ],
            ),
          ),

          // ID badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Text(
              investor.id.length > 8 ? '${investor.id.substring(0, 8)}…' : investor.id,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name, String lastName) {
    final first = name.isNotEmpty ? name[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.isNotEmpty ? '$first$last' : '?';
  }
}
