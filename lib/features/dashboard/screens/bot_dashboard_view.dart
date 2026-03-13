import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/locator.dart';
import '../../../core/services/fund_repository.dart';
import '../../../core/models/bot_state.dart';
import '../../../core/models/bot_snapshot.dart';
import '../../../core/theme/app_colors.dart';

class BotDashboardView extends StatelessWidget {
  const BotDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final cryptoFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 6);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bot de Trading',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.0),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Estado del smart contract',
                    style: TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              StreamBuilder<BotState?>(
                stream: fundRepo.streamBotState(),
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state == null) return const SizedBox();
                  return Row(
                    children: [
                      _buildPositionBadge(state.hasActivePosition),
                      const SizedBox(width: 12),
                      if (state.lastUpdateTimestamp != null) _buildTimeBadge(state.lastUpdateTimestamp!),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main content
          Expanded(
            child: StreamBuilder<BotState?>(
              stream: fundRepo.streamBotState(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error cargando el bot: ${snapshot.error}', style: const TextStyle(color: AppColors.error)),
                  );
                }
                final botState = snapshot.data;
                if (botState == null) {
                  return const Center(
                    child: Text('No hay información del bot.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return StreamBuilder<List<BotSnapshot>>(
                  stream: fundRepo.streamBotSnapshots(),
                  builder: (context, snapShotData) {
                    final snapshots = snapShotData.data ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HERO: Valor total USD
                          _buildHeroCard(botState, currencyFormat),
                          const SizedBox(height: 16),

                          // PnL BIMONETARIO
                          _buildPnlCard(botState, cryptoFormat, snapshots),
                          const SizedBox(height: 24),

                          // DESGLOSE POR TOKEN
                          const _SectionTitle('Desglose por Token'),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTokenBreakdownCard(
                                  symbol: 'WETH',
                                  icon: 'Ξ',
                                  color: const Color(0xFF627EEA),
                                  idle: botState.idleWeth,
                                  fees: botState.feesWeth,
                                  pool: botState.poolWeth,
                                  total: botState.totalWeth,
                                  initial: botState.initialWeth,
                                  delta: botState.deltaWeth,
                                  price: botState.priceWeth,
                                  cryptoFormat: cryptoFormat,
                                  currencyFormat: currencyFormat,
                                ),
                                const SizedBox(width: 16),
                                _buildTokenBreakdownCard(
                                  symbol: 'WBTC',
                                  icon: '₿',
                                  color: const Color(0xFFF7931A),
                                  idle: botState.idleWbtc,
                                  fees: botState.feesWbtc,
                                  pool: botState.poolWbtc,
                                  total: botState.totalWbtc,
                                  initial: botState.initialWbtc,
                                  delta: botState.deltaWbtc,
                                  price: botState.priceWbtc,
                                  cryptoFormat: cryptoFormat,
                                  currencyFormat: currencyFormat,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // PRECIOS & INFO
                          _buildInfoBar(botState, currencyFormat),
                          const SizedBox(height: 32),
                        ],
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

  // ══════════════════════════════════════════════════════════════════
  //  HEADER BADGES
  // ══════════════════════════════════════════════════════════════════

  Widget _buildPositionBadge(bool active) {
    final color = active ? AppColors.success : Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            active ? 'Posición Activa' : 'Sin Posición',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(DateTime lastUpdate) {
    final timeAgo = DateTime.now().difference(lastUpdate);
    final label = timeAgo.inMinutes < 60
        ? 'Hace ${timeAgo.inMinutes} min'
        : timeAgo.inHours < 24
            ? 'Hace ${timeAgo.inHours}h'
            : 'Hace ${timeAgo.inDays}d';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: AppColors.primaryCyan.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  HERO CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildHeroCard(BotState s, NumberFormat currencyFormat) {
    const color = AppColors.primaryCyan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy, color: color, size: 48),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALOR TOTAL DEL BOT (USD)',
                  style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(s.totalValueUsd),
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  PnL BIMONETARIO
  // ══════════════════════════════════════════════════════════════════

  Widget _buildPnlCard(BotState s, NumberFormat cryptoFormat, List<BotSnapshot> snapshots) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white.withValues(alpha: 0.4), size: 18),
              const SizedBox(width: 8),
              Text(
                'PnL BIMONETARIO',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Text(
                  'Rentabilidad neta',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 9, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // PnL values
          // El % se calcula contra el portafolio total inicial valorizado
          // en cada moneda, no solo el inicial de ese token.
          Row(
            children: [
              Expanded(child: _buildPnlItem(
                'WETH', s.pnlWeth,
                s.initialWeth + (s.initialWbtc * s.poolPriceWbtcInWeth),
                cryptoFormat, const Color(0xFF627EEA),
              )),
              Container(width: 1, height: 60, color: AppColors.borderDark, margin: const EdgeInsets.symmetric(horizontal: 20)),
              Expanded(child: _buildPnlItem(
                'WBTC', s.pnlWbtc,
                s.poolPriceWbtcInWeth > 0
                    ? s.initialWbtc + (s.initialWeth / s.poolPriceWbtcInWeth)
                    : s.initialWbtc,
                cryptoFormat, const Color(0xFFF7931A),
              )),
            ],
          ),

          // Sparklines
          if (snapshots.length >= 2) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: _buildSparkline(snapshots, (snap) => snap.pnlWeth, const Color(0xFF627EEA)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: _buildSparkline(snapshots, (snap) => snap.pnlWbtc, const Color(0xFFF7931A)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPnlItem(String token, double pnl, double initial, NumberFormat format, Color tokenColor) {
    final isPositive = pnl >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final pctValue = initial > 0 ? (pnl / initial) * 100 : 0.0;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'EN $token',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${pctValue.toStringAsFixed(2)}%',
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${format.format(pnl)}',
                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SPARKLINE
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSparkline(List<BotSnapshot> snapshots, double Function(BotSnapshot) extractor, Color baseColor) {
    final spots = <FlSpot>[];
    for (int i = 0; i < snapshots.length; i++) {
      spots.add(FlSpot(i.toDouble(), extractor(snapshots[i])));
    }
    if (spots.length < 2) return const SizedBox();

    final allY = spots.map((s) => s.y);
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range == 0 ? 0.001 : range * 0.2;

    final lastVal = spots.last.y;
    final lineColor = lastVal >= 0 ? AppColors.success : AppColors.error;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LineChart(
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
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final snapIndex = spot.x.toInt().clamp(0, snapshots.length - 1);
                  final snap = snapshots[snapIndex];
                  final dateStr = snap.timestamp != null ? DateFormat('dd MMM').format(snap.timestamp!) : '';
                  return LineTooltipItem(
                    '${spot.y >= 0 ? '+' : ''}${spot.y.toStringAsFixed(6)}\n$dateStr',
                    TextStyle(color: spot.y >= 0 ? AppColors.success : AppColors.error, fontSize: 11, fontWeight: FontWeight.w800),
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
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [lineColor.withValues(alpha: 0.12), lineColor.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                cutOffY: 0,
                applyCutOffY: true,
              ),
              aboveBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppColors.error.withValues(alpha: 0.0), AppColors.error.withValues(alpha: 0.08)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                cutOffY: 0,
                applyCutOffY: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  TOKEN BREAKDOWN CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildTokenBreakdownCard({
    required String symbol,
    required String icon,
    required Color color,
    required double idle,
    required double fees,
    required double pool,
    required double total,
    required double initial,
    required double delta,
    required double price,
    required NumberFormat cryptoFormat,
    required NumberFormat currencyFormat,
  }) {
    final isPositiveDelta = delta >= 0;
    final deltaColor = isPositiveDelta ? AppColors.success : AppColors.error;
    final totalValueUsd = total * price;

    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.0),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 8))],
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.surfaceDark, AppColors.backgroundDark]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
                child: Center(child: Text(icon, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  Text(currencyFormat.format(price), style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const Spacer(),
              // Delta badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: deltaColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isPositiveDelta ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: deltaColor, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '${isPositiveDelta ? '+' : ''}${cryptoFormat.format(delta)}',
                      style: TextStyle(color: deltaColor, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3 component rows: Idle / Fees / Pool
          _buildComponentRow('IDLE', Icons.account_balance_wallet_outlined, idle, Colors.white38, cryptoFormat),
          const SizedBox(height: 8),
          _buildComponentRow('FEES', Icons.payments_outlined, fees, AppColors.success, cryptoFormat),
          const SizedBox(height: 8),
          _buildComponentRow('POOL', Icons.water_drop_outlined, pool, color, cryptoFormat),
          const SizedBox(height: 16),

          // Total + USD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      cryptoFormat.format(total),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VALOR USD', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(totalValueUsd), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Inicial
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('INICIAL  ', style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              Text(
                cryptoFormat.format(initial),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentRow(String label, IconData icon, double value, Color accent, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.6), size: 14),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: accent.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const Spacer(),
          Text(
            format.format(value),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  INFO BAR (precios + pool price)
  // ══════════════════════════════════════════════════════════════════

  Widget _buildInfoBar(BotState s, NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('WETH', currencyFormat.format(s.priceWeth), const Color(0xFF627EEA)),
          _buildInfoDivider(),
          _buildInfoItem('WBTC', currencyFormat.format(s.priceWbtc), const Color(0xFFF7931A)),
          _buildInfoDivider(),
          _buildInfoItem('POL', currencyFormat.format(s.pricePol), const Color(0xFF8247E5)),
          _buildInfoDivider(),
          _buildInfoItem('1 WBTC', '${s.poolPriceWbtcInWeth.toStringAsFixed(4)} WETH', Colors.white54, subtitle: 'Pool Price'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color, {String? subtitle}) {
    return Column(
      children: [
        if (subtitle != null)
          Text(subtitle.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        if (subtitle != null) const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildInfoDivider() => Container(width: 1, height: 36, color: AppColors.borderDark);
}

// ══════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
    );
  }
}
