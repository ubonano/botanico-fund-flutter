import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/operation.dart';
import '../../../../core/models/fund_state.dart';
import '../../../../core/theme/app_colors.dart';

class InvestorDetailDialog extends StatelessWidget {
  final Investor investor;
  final Color colorTheme;

  const InvestorDetailDialog({super.key, required this.investor, required this.colorTheme});

  static void show(BuildContext context, {required Investor investor, required Color colorTheme}) {
    showDialog(
      context: context,
      builder: (context) => InvestorDetailDialog(investor: investor, colorTheme: colorTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final cryptoFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 4);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final sharesFormat = NumberFormat('#,##0.00', 'en_US');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 620),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.surfaceDark, AppColors.backgroundDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorTheme.withValues(alpha: 0.2), width: 1.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // BODY con scroll
              Expanded(
                child: StreamBuilder<FundState?>(
                  stream: fundRepo.streamCurrentFundState(),
                  builder: (context, stateSnapshot) {
                    final fundState = stateSnapshot.data;
                    final currentNavUsd = fundState?.navUsd ?? 0.0;

                    final currentValueUsd = investor.currentShares * currentNavUsd;
                    final pnlNetoUsd = currentValueUsd - investor.netInvestmentUsd;

                    final participation = fundState != null && fundState.totalShares > 0
                        ? (investor.currentShares / fundState.totalShares) * 100
                        : 0.0;

                    final isPositiveUsd = pnlNetoUsd >= 0;

                    return Column(
                      children: [
                        // HEADER con datos del fund state
                        _buildHeader(context, participation, sharesFormat),
                        // BODY
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT PANEL: Resumen
                              SizedBox(
                                width: 340,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Valor actual hero
                                      _buildValueHero(
                                        currentValueUsd: currentValueUsd,
                                        pnlNetoUsd: pnlNetoUsd,
                                        isPositive: isPositiveUsd,
                                        currencyFormat: currencyFormat,
                                      ),
                                      const SizedBox(height: 16),

                                      // ROI en las 3 denominaciones
                                      _buildRoiSection(),
                                      const SizedBox(height: 16),

                                      // NAV Promedio de compra
                                      _buildSection(
                                        icon: Icons.speed_outlined,
                                        title: 'NAV PROMEDIO DE COMPRA',
                                        child: Text(
                                          currencyFormat.format(investor.avgPurchaseNavUsd),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Inversión Neta
                                      _buildInvestmentSection(
                                        currencyFormat: currencyFormat,
                                        cryptoFormat: cryptoFormat,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Divider vertical
                              Container(width: 1, color: Colors.white.withValues(alpha: 0.06)),

                              // RIGHT PANEL: Operaciones
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.receipt_long, color: Colors.white38, size: 18),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'HISTORIAL DE OPERACIONES',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(child: _buildOperationsList(fundRepo, currencyFormat, dateFormat)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double participation, NumberFormat sharesFormat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorTheme.withValues(alpha: 0.3), colorTheme.withValues(alpha: 0.1)]),
              shape: BoxShape.circle,
              border: Border.all(color: colorTheme.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                investor.name.isNotEmpty ? investor.name[0].toUpperCase() : '?',
                style: TextStyle(color: colorTheme, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investor.name.isNotEmpty ? investor.name : investor.id,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Detalle del inversor',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          // Cuotapartes + Participación integrados
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorTheme.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorTheme.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pie_chart_outline, size: 14, color: colorTheme.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  sharesFormat.format(investor.currentShares),
                  style: TextStyle(
                    color: colorTheme,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'cp',
                  style: TextStyle(color: colorTheme.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 16, color: colorTheme.withValues(alpha: 0.2)),
                const SizedBox(width: 10),
                Text(
                  '${participation.toStringAsFixed(2)}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.white38, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueHero({
    required double currentValueUsd,
    required double pnlNetoUsd,
    required bool isPositive,
    required NumberFormat currencyFormat,
  }) {
    final pnlColor = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorTheme.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorTheme.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VALOR ACTUAL',
            style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormat.format(currentValueUsd),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(isPositive ? Icons.trending_up : Icons.trending_down, size: 16, color: pnlColor),
              const SizedBox(width: 6),
              Text(
                '${isPositive ? '+' : ''}${currencyFormat.format(pnlNetoUsd)}',
                style: TextStyle(color: pnlColor, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
              ),
              const Spacer(),
              Text(
                'ROI',
                style: TextStyle(
                  color: pnlColor.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${isPositive ? '+' : ''}${(investor.roiUsd * 100).toStringAsFixed(2)}%',
                style: TextStyle(color: pnlColor, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoiSection() {
    return _buildSection(
      icon: Icons.show_chart,
      title: 'RENDIMIENTO POR DENOMINACIÓN',
      child: Row(
        children: [
          Expanded(child: _buildRoiChip('BTC', investor.roiWbtc, const Color(0xFFF7931A))),
          const SizedBox(width: 8),
          Expanded(child: _buildRoiChip('ETH', investor.roiWeth, const Color(0xFF627EEA))),
        ],
      ),
    );
  }

  Widget _buildRoiChip(String label, double roi, Color color) {
    final isPositive = roi >= 0;
    final pnlColor = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            '${isPositive ? '+' : ''}${(roi * 100).toStringAsFixed(2)}%',
            style: TextStyle(color: pnlColor, fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentSection({required NumberFormat currencyFormat, required NumberFormat cryptoFormat}) {
    return _buildSection(
      icon: Icons.account_balance_wallet_outlined,
      title: 'INVERSIÓN NETA',
      child: Column(
        children: [
          _buildDataRow('USD', currencyFormat.format(investor.netInvestmentUsd), Colors.white70),
          const SizedBox(height: 6),
          _buildDataRow('WBTC', cryptoFormat.format(investor.netInvestmentWbtc), const Color(0xFFF7931A)),
          const SizedBox(height: 6),
          _buildDataRow('WETH', cryptoFormat.format(investor.netInvestmentWeth), const Color(0xFF627EEA)),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.white38),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildOperationsList(FundRepository fundRepo, NumberFormat currencyFormat, DateFormat dateFormat) {
    return StreamBuilder<List<Operation>>(
      stream: fundRepo.streamInvestorOperations(investor.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)),
          );
        }

        final operations = snapshot.data;

        if (operations == null || operations.isEmpty) {
          return const Center(
            child: Text('No hay operaciones registradas.', style: TextStyle(color: Colors.white38)),
          );
        }

        return ListView.separated(
          itemCount: operations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final op = operations[index];
            final isDeposit = op.type == 'DEPOSIT';
            final opColor = isDeposit ? AppColors.success : AppColors.error;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: opColor.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: opColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  // Icono
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: opColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: opColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isDeposit ? 'Depósito' : 'Retiro',
                              style: TextStyle(color: opColor, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormat.format(op.amountUsd),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              op.timestamp != null ? dateFormat.format(op.timestamp!) : 'Fecha desconocida',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            Row(
                              children: [
                                Text(
                                  'NAV ${currencyFormat.format(op.navUsdApplied)}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${op.sharesOperated.toStringAsFixed(2)} cp',
                                  style: TextStyle(
                                    color: colorTheme.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
