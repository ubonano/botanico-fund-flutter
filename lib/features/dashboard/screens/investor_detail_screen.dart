import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/investor_snapshot.dart';
import '../../../../core/models/operation.dart';
import '../../../../core/models/fund_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/shared/token_card.dart';
import 'capital_movement_dialog.dart';

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
    final cryptoFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 6);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final sharesFormat = NumberFormat('#,##0.00', 'en_US');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
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
              Expanded(
                child: StreamBuilder<FundState?>(
                  stream: fundRepo.streamCurrentFundState(),
                  builder: (context, stateSnapshot) {
                    final fundState = stateSnapshot.data;

                    final currentValueUsd = investor.currentShares * (fundState?.navUsd ?? 0.0);
                    final currentValueWbtc = investor.currentShares * (fundState?.navWbtc ?? 0.0);
                    final currentValueWeth = investor.currentShares * (fundState?.navWeth ?? 0.0);

                    final variationUsd = currentValueUsd - investor.netInvestmentUsd;
                    final variationWbtc = currentValueWbtc - investor.netInvestmentWbtc;
                    final variationWeth = currentValueWeth - investor.netInvestmentWeth;

                    final participation = fundState != null && fundState.totalShares > 0
                        ? (investor.currentShares / fundState.totalShares) * 100
                        : 0.0;

                    return Column(
                      children: [
                        _buildHeader(context, participation, sharesFormat),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT PANEL: 3 Token Cards
                              SizedBox(
                                width: 380,
                                child: StreamBuilder<List<InvestorSnapshot>>(
                                  stream: fundRepo.streamInvestorSnapshots(investor.id),
                                  builder: (context, snapshotSnap) {
                                    final snapshots = snapshotSnap.data ?? [];

                                    return SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          TokenCard(
                                            tokenSymbol: 'WBTC',
                                            tokenIcon: '₿',
                                            tokenColor: const Color(0xFFF7931A),
                                            netInvestment: investor.netInvestmentWbtc,
                                            currentValue: currentValueWbtc,
                                            roi: investor.roiWbtc,
                                            nominalVariation: variationWbtc,
                                            formatValue: (v) => cryptoFormat.format(v),
                                            roiSpots: _buildRoiSpots(snapshots, (s) => s.roiWbtc),
                                            spotTimestamps: snapshots.map((s) => s.timestamp).toList(),
                                          ),
                                          const SizedBox(height: 12),
                                          TokenCard(
                                            tokenSymbol: 'WETH',
                                            tokenIcon: 'Ξ',
                                            tokenColor: const Color(0xFF627EEA),
                                            netInvestment: investor.netInvestmentWeth,
                                            currentValue: currentValueWeth,
                                            roi: investor.roiWeth,
                                            nominalVariation: variationWeth,
                                            formatValue: (v) => cryptoFormat.format(v),
                                            roiSpots: _buildRoiSpots(snapshots, (s) => s.roiWeth),
                                            spotTimestamps: snapshots.map((s) => s.timestamp).toList(),
                                          ),
                                          const SizedBox(height: 12),
                                          TokenCard(
                                            tokenSymbol: 'USD',
                                            tokenIcon: '\$',
                                            tokenColor: AppColors.primaryViolet,
                                            netInvestment: investor.netInvestmentUsd,
                                            currentValue: currentValueUsd,
                                            roi: investor.roiUsd,
                                            nominalVariation: variationUsd,
                                            formatValue: (v) => currencyFormat.format(v),
                                            roiSpots: _buildRoiSpots(snapshots, (s) => s.roiUsd),
                                            spotTimestamps: snapshots.map((s) => s.timestamp).toList(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
          // Cuotapartes + Participación
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
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              CapitalMovementDialog.show(
                context,
                investorId: investor.id,
                investorName: investor.name.isNotEmpty ? investor.name : investor.id,
                colorTheme: colorTheme,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.success.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  const Text(
                    'Nuevo Movimiento',
                    style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
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

  List<FlSpot> _buildRoiSpots(List<InvestorSnapshot> snapshots, double Function(InvestorSnapshot) extractor) {
    return List.generate(snapshots.length, (i) => FlSpot(i.toDouble(), extractor(snapshots[i]) * 100));
  }

  /// Retorna (color, icono, etiqueta) según el tipo de operación.
  static const _commissionAmber = Color(0xFFF59E0B);

  ({Color color, IconData icon, String label}) _operationStyle(String type) {
    return switch (type) {
      'DEPOSIT' => (color: AppColors.success, icon: Icons.arrow_downward, label: 'Depósito'),
      'WITHDRAWAL' => (color: AppColors.error, icon: Icons.arrow_upward, label: 'Retiro'),
      'COMMISSION' => (color: _commissionAmber, icon: Icons.percent, label: 'Comisión'),
      'COMMISSION_INCOME' => (color: AppColors.primaryCyan, icon: Icons.account_balance, label: 'Ingreso Comisión'),
      _ => (color: Colors.white38, icon: Icons.help_outline, label: type),
    };
  }

  Widget _buildOperationsList(FundRepository fundRepo, NumberFormat currencyFormat, DateFormat dateFormat) {
    return StreamBuilder<List<Operation>>(
      stream: fundRepo.streamInvestorOperations(investor.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
            final style = _operationStyle(op.type);
            final displayAmount = switch (op.type) {
              'COMMISSION' => op.commissionUsd,
              'COMMISSION_INCOME' => op.totalCommissionUsd,
              _ => op.amountUsd,
            };

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: style.color.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(style.icon, color: style.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              style.label,
                              style: TextStyle(color: style.color, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormat.format(displayAmount),
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
