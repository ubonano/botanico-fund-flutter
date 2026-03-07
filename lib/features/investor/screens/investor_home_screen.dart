import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:botanico_fund_flutter/core/config/locator.dart';
import 'package:botanico_fund_flutter/core/services/auth_service.dart';
import 'package:botanico_fund_flutter/core/services/fund_repository.dart';
import 'package:botanico_fund_flutter/core/models/investor.dart';
import 'package:botanico_fund_flutter/core/models/investor_snapshot.dart';
import 'package:botanico_fund_flutter/core/models/fund_state.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';

/// Pantalla principal para usuarios con rol `investor`.
///
/// Muestra 3 tarjetas apiladas (WBTC, WETH, USD) con inversión neta,
/// valor actual, ROI, variación nominal y un gráfico lineal de evolución
/// del ROI basado en los snapshots diarios del inversor.
class InvestorHomeScreen extends StatefulWidget {
  final String investorId;

  const InvestorHomeScreen({super.key, required this.investorId});

  @override
  State<InvestorHomeScreen> createState() => _InvestorHomeScreenState();
}

class _InvestorHomeScreenState extends State<InvestorHomeScreen> with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  static const int _itemCount = 5; // logo, welcome, 3 cards

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnimations = List.generate(_itemCount, (i) {
      final start = i * 0.14;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List.generate(_itemCount, (i) {
      final start = i * 0.14;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
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
    final fundRepo = locator<FundRepository>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final cryptoFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 6);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: StreamBuilder<Investor?>(
        stream: fundRepo.streamInvestor(widget.investorId),
        builder: (context, investorSnap) {
          if (investorSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final investor = investorSnap.data;
          if (investor == null) {
            return const Center(
              child: Text('No se encontró información del inversor.', style: TextStyle(color: Colors.white54)),
            );
          }

          return StreamBuilder<FundState?>(
            stream: fundRepo.streamCurrentFundState(),
            builder: (context, fundSnap) {
              final fundState = fundSnap.data;
              final currentValueUsd = investor.currentShares * (fundState?.navUsd ?? 0.0);
              final currentValueWbtc = investor.currentShares * (fundState?.navWbtc ?? 0.0);
              final currentValueWeth = investor.currentShares * (fundState?.navWeth ?? 0.0);

              final variationUsd = currentValueUsd - investor.netInvestmentUsd;
              final variationWbtc = currentValueWbtc - investor.netInvestmentWbtc;
              final variationWeth = currentValueWeth - investor.netInvestmentWeth;

              return StreamBuilder<List<InvestorSnapshot>>(
                stream: fundRepo.streamInvestorSnapshots(widget.investorId),
                builder: (context, snapshotSnap) {
                  final snapshots = snapshotSnap.data ?? [];

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                        child: Column(
                          children: [
                            // ── Logo ──
                            _buildAnimated(0, _buildLogo()),
                            const SizedBox(height: 6),

                            // ── Welcome ──
                            _buildAnimated(1, _buildWelcome(investor)),
                            const SizedBox(height: 28),

                            // ── Card WBTC ──
                            _buildAnimated(
                              2,
                              _TokenCard(
                                tokenSymbol: 'WBTC',
                                tokenIcon: '₿',
                                tokenColor: const Color(0xFFF7931A),
                                netInvestment: investor.netInvestmentWbtc,
                                currentValue: currentValueWbtc,
                                roi: investor.roiWbtc,
                                nominalVariation: variationWbtc,
                                formatValue: (v) => cryptoFormat.format(v),
                                snapshots: snapshots,
                                roiExtractor: (s) => s.roiWbtc,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Card WETH ──
                            _buildAnimated(
                              3,
                              _TokenCard(
                                tokenSymbol: 'WETH',
                                tokenIcon: 'Ξ',
                                tokenColor: const Color(0xFF627EEA),
                                netInvestment: investor.netInvestmentWeth,
                                currentValue: currentValueWeth,
                                roi: investor.roiWeth,
                                nominalVariation: variationWeth,
                                formatValue: (v) => cryptoFormat.format(v),
                                snapshots: snapshots,
                                roiExtractor: (s) => s.roiWeth,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Card USD ──
                            _buildAnimated(
                              4,
                              _TokenCard(
                                tokenSymbol: 'USD',
                                tokenIcon: '\$',
                                tokenColor: AppColors.primaryViolet,
                                netInvestment: investor.netInvestmentUsd,
                                currentValue: currentValueUsd,
                                roi: investor.roiUsd,
                                nominalVariation: variationUsd,
                                formatValue: (v) => currencyFormat.format(v),
                                snapshots: snapshots,
                                roiExtractor: (s) => s.roiUsd,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // ── Logout ──
                            _buildLogoutButton(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimated(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Image.asset('assets/images/botanico_logo.png', width: 300, height: 300, fit: BoxFit.contain);
  }

  // ── Welcome ───────────────────────────────────────────────────────

  Widget _buildWelcome(Investor investor) {
    return Column(
      children: [
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Hola, ${investor.name}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.3),
          ),
        ),
        const SizedBox(height: 4),
        const Text('Estado de tu fondo', style: TextStyle(color: Colors.white30, fontSize: 13)),
      ],
    );
  }

  // ── Logout ────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return SizedBox(
      width: 170,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 15),
        label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white30,
          side: const BorderSide(color: AppColors.borderDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  TOKEN CARD — Reutilizable por cada denominación
// ═══════════════════════════════════════════════════════════════════════

class _TokenCard extends StatelessWidget {
  final String tokenSymbol;
  final String tokenIcon;
  final Color tokenColor;
  final double netInvestment;
  final double currentValue;
  final double roi;
  final double nominalVariation;
  final String Function(double) formatValue;
  final List<InvestorSnapshot> snapshots;
  final double Function(InvestorSnapshot) roiExtractor;

  const _TokenCard({
    required this.tokenSymbol,
    required this.tokenIcon,
    required this.tokenColor,
    required this.netInvestment,
    required this.currentValue,
    required this.roi,
    required this.nominalVariation,
    required this.formatValue,
    required this.snapshots,
    required this.roiExtractor,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = roi >= 0;
    final roiColor = isPositive ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokenColor.withValues(alpha: 0.12)),
        gradient: LinearGradient(
          colors: [tokenColor.withValues(alpha: 0.06), tokenColor.withValues(alpha: 0.01), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // ── Header: Token identity ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                // Token icon badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tokenColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: tokenColor.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text(
                      tokenIcon,
                      style: TextStyle(color: tokenColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  tokenSymbol,
                  style: TextStyle(color: tokenColor, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
                const Spacer(),
                // ROI Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: roiColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: roiColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: roiColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${(roi * 100).toStringAsFixed(2)}%',
                        style: TextStyle(color: roiColor, fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Data Section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Left: Valor Actual (big)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VALOR ACTUAL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatValue(currentValue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nominal variation
                      Text(
                        '${nominalVariation >= 0 ? '+' : ''}${formatValue(nominalVariation)}',
                        style: TextStyle(
                          color: roiColor.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Inversión Neta
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'INVERSIÓN NETA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatValue(netInvestment),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Chart ──
          SizedBox(
            height: 70,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: _buildChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (snapshots.isEmpty) {
      return Center(
        child: Text('Sin datos históricos', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11)),
      );
    }

    // Build FlSpots from snapshot ROI data (converted to %)
    final spots = <FlSpot>[];
    for (int i = 0; i < snapshots.length; i++) {
      final roiValue = roiExtractor(snapshots[i]) * 100; // to percentage
      spots.add(FlSpot(i.toDouble(), roiValue));
    }

    if (spots.length < 2) {
      return Center(
        child: Text('Datos insuficientes', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11)),
      );
    }

    final allY = spots.map((s) => s.y);
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range == 0 ? 1.0 : range * 0.2;

    // Determine line color: green if last ROI >= 0, red if < 0
    final lastRoi = spots.last.y;
    final lineColor = lastRoi >= 0 ? AppColors.success : AppColors.error;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        clipData: const FlClipData.all(),
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final snapIndex = spot.x.toInt().clamp(0, snapshots.length - 1);
                final snap = snapshots[snapIndex];
                final dateStr = snap.timestamp != null ? DateFormat('dd MMM').format(snap.timestamp!) : '';
                return LineTooltipItem(
                  '${spot.y >= 0 ? '+' : ''}${spot.y.toStringAsFixed(2)}%\n$dateStr',
                  TextStyle(
                    color: spot.y >= 0 ? AppColors.success : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                );
              }).toList();
            },
          ),
        ),
        // Zero line reference
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(y: 0, color: Colors.white.withValues(alpha: 0.1), strokeWidth: 1, dashArray: [4, 4]),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor.withValues(alpha: 0.85),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [lineColor.withValues(alpha: 0.15), lineColor.withValues(alpha: 0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // Only show fill above the zero line for positive, below for negative
              cutOffY: 0,
              applyCutOffY: true,
            ),
            aboveBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.error.withValues(alpha: 0.0), AppColors.error.withValues(alpha: 0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              cutOffY: 0,
              applyCutOffY: true,
            ),
          ),
        ],
      ),
    );
  }
}
