import 'package:flutter/material.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/fund_state.dart';
import 'package:fl_chart/fl_chart.dart';
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
          const Text(
            'Lista de Inversores',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Investor>>(
              stream: fundRepo.streamInvestors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading investors: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFF43F5E)),
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

                    return Column(
                      children: [
                        if (investors.isNotEmpty &&
                            fundState != null &&
                            fundState.totalShares > 0)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.surfaceDark,
                                        AppColors.backgroundDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 220,
                                        child: PieChart(
                                          PieChartData(
                                            sectionsSpace: 2,
                                            centerSpaceRadius: 50,
                                            sections: investors
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                                  final index = entry.key;
                                                  final inv = entry.value;
                                                  final percent =
                                                      (inv.currentShares /
                                                          fundState
                                                              .totalShares) *
                                                      100;

                                                  // Skip if shares are practically 0
                                                  if (inv.currentShares <= 0) {
                                                    return PieChartSectionData(
                                                      value: 0,
                                                      radius: 0,
                                                      title: '',
                                                    );
                                                  }

                                                  return PieChartSectionData(
                                                    color:
                                                        colors[index %
                                                            colors.length],
                                                    value: inv.currentShares,
                                                    title:
                                                        '${inv.name.isNotEmpty ? inv.name : 'Desc.'}\n${percent.toStringAsFixed(1)}%',
                                                    radius: 75,
                                                    titlePositionPercentageOffset:
                                                        0.55,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black54,
                                                          blurRadius: 4,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                                .toList()
                                                .where((s) => s.value > 0)
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child:
                                    Container(), // Espacio vacío por ahora como solicitó el usuario
                              ),
                            ],
                          ),
                        if (investors.isNotEmpty &&
                            fundState != null &&
                            fundState.totalShares > 0)
                          const SizedBox(height: 24),
                        Expanded(
                          child: ListView.separated(
                            itemCount: investors.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final investor = investors[index];
                              final currentValueUsd =
                                  investor.currentShares * currentNavUsd;
                              final pnlNetoUsd =
                                  currentValueUsd - investor.netInvestmentUsd;
                              final avgNavUsd = investor.currentShares > 0
                                  ? investor.netInvestmentUsd /
                                        investor.currentShares
                                  : 0.0;
                              final colorTheme = colors[index % colors.length];

                              final participation =
                                  fundState != null && fundState.totalShares > 0
                                  ? (investor.currentShares /
                                            fundState.totalShares) *
                                        100
                                  : 0.0;

                              final currencyFormat = NumberFormat.currency(
                                locale: 'en_US',
                                symbol: '\$',
                              );
                              final sharesFormat = NumberFormat.currency(
                                locale: 'en_US',
                                symbol: '',
                                decimalDigits: 2,
                              );

                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InvestorDetailScreen(
                                            investor: investor,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colorTheme.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorTheme.withOpacity(0.05),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: colorTheme
                                                .withOpacity(0.2),
                                            child: Text(
                                              investor.name.isNotEmpty
                                                  ? investor.name[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                color: colorTheme,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  investor.name.isNotEmpty
                                                      ? investor.name
                                                      : investor.id,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Participación: ${participation.toStringAsFixed(2)}%',
                                                  style: TextStyle(
                                                    color: colorTheme,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white24,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Secciones de información secundaria
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildMetricCol(
                                              icon: Icons.pie_chart_outline,
                                              label: 'Cuotapartes',
                                              value: sharesFormat.format(
                                                investor.currentShares,
                                              ),
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildMetricCol(
                                              icon: Icons
                                                  .account_balance_wallet_outlined,
                                              label: 'Inversión Neta',
                                              value: currencyFormat.format(
                                                investor.netInvestmentUsd,
                                              ),
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildMetricCol(
                                              icon: Icons.show_chart,
                                              label: 'NAV Prom.',
                                              value: currencyFormat.format(
                                                avgNavUsd,
                                              ),
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Sección Premium Combinada: Valor Actual y Rendimientos
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundDark
                                              .withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: pnlNetoUsd >= 0
                                                ? AppColors.success.withOpacity(
                                                    0.2,
                                                  )
                                                : AppColors.error.withOpacity(
                                                    0.2,
                                                  ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Valor Actual',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      currencyFormat.format(
                                                        currentValueUsd,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: pnlNetoUsd >= 0
                                                        ? AppColors.success
                                                              .withOpacity(0.1)
                                                        : AppColors.error
                                                              .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        pnlNetoUsd >= 0
                                                            ? Icons.arrow_upward
                                                            : Icons
                                                                  .arrow_downward,
                                                        size: 14,
                                                        color: pnlNetoUsd >= 0
                                                            ? AppColors.success
                                                            : AppColors.error,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${(investor.roiUsd * 100).toStringAsFixed(2)}%',
                                                        style: TextStyle(
                                                          color: pnlNetoUsd >= 0
                                                              ? AppColors
                                                                    .success
                                                              : AppColors.error,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(
                                              color: Colors.white10,
                                              height: 1,
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.account_balance,
                                                  size: 14,
                                                  color: Colors.white54,
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Ganancia / Pérdida (PNL):',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${pnlNetoUsd >= 0 ? '+' : ''}${currencyFormat.format(pnlNetoUsd)}',
                                                  style: TextStyle(
                                                    color: pnlNetoUsd >= 0
                                                        ? AppColors.success
                                                        : AppColors.error,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
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
                            },
                          ),
                        ),
                      ],
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

  Widget _buildMetricCol({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
