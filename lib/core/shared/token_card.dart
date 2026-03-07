import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:botanico_fund_flutter/core/models/investor_snapshot.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';

/// Tarjeta reutilizable que muestra el estado de un token (WBTC, WETH o USD)
/// con inversión neta, valor actual, ROI, variación nominal y gráfico
/// de evolución del ROI basado en snapshots diarios del inversor.
class TokenCard extends StatelessWidget {
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

  const TokenCard({
    super.key,
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
                // Left: Valor Actual
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

    final spots = <FlSpot>[];
    for (int i = 0; i < snapshots.length; i++) {
      spots.add(FlSpot(i.toDouble(), roiExtractor(snapshots[i]) * 100));
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
