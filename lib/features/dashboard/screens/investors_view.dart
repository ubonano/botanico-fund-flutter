import 'package:flutter/material.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/fund_state.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import 'investor_detail_screen.dart';

class InvestorsView extends StatelessWidget {
  const InvestorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inversores',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gestión de participantes del fondo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Investor>>(
              stream: fundRepo.streamInvestors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error cargando inversores: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                final investors = snapshot.data;

                if (investors == null || investors.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron inversores.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return StreamBuilder<FundState?>(
                  stream: fundRepo.streamCurrentFundState(),
                  builder: (context, stateSnapshot) {
                    final fundState = stateSnapshot.data;
                    final currentNavUsd = fundState?.navUsd ?? 0.0;
                    final colors = AppColors.chartColors;

                    final currencyFormat = NumberFormat.currency(
                      locale: 'en_US',
                      symbol: '\$',
                    );

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: investors.asMap().entries.map((entry) {
                          final index = entry.key;
                          final investor = entry.value;
                          final currentValueUsd =
                              investor.currentShares * currentNavUsd;
                          final pnlNetoUsd =
                              currentValueUsd - investor.netInvestmentUsd;
                          final colorTheme = colors[index % colors.length];
                          final participation =
                              fundState != null && fundState.totalShares > 0
                              ? (investor.currentShares /
                                        fundState.totalShares) *
                                    100
                              : 0.0;

                          return _buildInvestorCard(
                            context: context,
                            investor: investor,
                            currentValueUsd: currentValueUsd,
                            pnlNetoUsd: pnlNetoUsd,
                            participation: participation,
                            colorTheme: colorTheme,
                            currencyFormat: currencyFormat,
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorCard({
    required BuildContext context,
    required Investor investor,
    required double currentValueUsd,
    required double pnlNetoUsd,
    required double participation,
    required Color colorTheme,
    required NumberFormat currencyFormat,
  }) {
    final isPositive = pnlNetoUsd >= 0;
    final pnlColor = isPositive ? AppColors.success : AppColors.error;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvestorDetailScreen(investor: investor),
          ),
        );
      },
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceDark, AppColors.backgroundDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorTheme.withValues(alpha: 0.15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: colorTheme.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Avatar + Nombre + Participación
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorTheme.withValues(alpha: 0.3),
                        colorTheme.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorTheme.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      investor.name.isNotEmpty
                          ? investor.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colorTheme,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.name.isNotEmpty ? investor.name : investor.id,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: colorTheme,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${participation.toStringAsFixed(2)}% del fondo',
                            style: TextStyle(
                              color: colorTheme.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white12,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // BODY: Valor Actual + Rendimiento unificado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorTheme.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorTheme.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Valor actual
                  const Text(
                    'VALOR ACTUAL',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(currentValueUsd),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Divider sutil
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 10),
                  // PNL + ROI en una sola fila
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 18,
                        color: pnlColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isPositive ? '+' : ''}${currencyFormat.format(pnlNetoUsd)}',
                        style: TextStyle(
                          color: pnlColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ROI',
                        style: TextStyle(
                          color: pnlColor.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${isPositive ? '+' : ''}${(investor.roiUsd * 100).toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: pnlColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
