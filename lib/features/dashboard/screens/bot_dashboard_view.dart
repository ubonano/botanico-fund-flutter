import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/locator.dart';
import '../../../core/services/fund_repository.dart';
import '../../../core/services/fund_functions_service.dart';
import '../../../core/models/bot_state.dart';
import '../../../core/models/bot_snapshot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/shared/token_card.dart';
import 'bot_config_dialog.dart';

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
              Row(
                children: [
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
                  const SizedBox(width: 12),
                  _BotToggleButton(),
                  const SizedBox(width: 8),
                  _buildConfigButton(context),
                ],
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

                    final spotTimestamps = snapshots.map((s) => s.timestamp).toList();

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            children: [
                              // ── Token Cards ──
                              TokenCard(
                                tokenSymbol: 'WBTC',
                                tokenIcon: '₿',
                                tokenColor: const Color(0xFFF7931A),
                                netInvestment: botState.initialValueWbtc,
                                currentValue: botState.totalValueWbtc,
                                roi: botState.roiWbtc,
                                nominalVariation: botState.totalValueWbtc - botState.initialValueWbtc,
                                formatValue: (v) => cryptoFormat.format(v),
                                roiSpots: _buildBotRoiSpots(snapshots, (s) => s.roiWbtc),
                                spotTimestamps: spotTimestamps,
                              ),
                              const SizedBox(height: 16),

                              TokenCard(
                                tokenSymbol: 'WETH',
                                tokenIcon: 'Ξ',
                                tokenColor: const Color(0xFF627EEA),
                                netInvestment: botState.initialValueWeth,
                                currentValue: botState.totalValueWeth,
                                roi: botState.roiWeth,
                                nominalVariation: botState.totalValueWeth - botState.initialValueWeth,
                                formatValue: (v) => cryptoFormat.format(v),
                                roiSpots: _buildBotRoiSpots(snapshots, (s) => s.roiWeth),
                                spotTimestamps: spotTimestamps,
                              ),
                              const SizedBox(height: 16),

                              TokenCard(
                                tokenSymbol: 'USD',
                                tokenIcon: '\$',
                                tokenColor: AppColors.primaryViolet,
                                netInvestment: botState.initialValueUsd,
                                currentValue: botState.totalValueUsd,
                                roi: botState.roiUsd,
                                nominalVariation: botState.totalValueUsd - botState.initialValueUsd,
                                formatValue: (v) => currencyFormat.format(v),
                                roiSpots: _buildBotRoiSpots(snapshots, (s) => s.roiUsd),
                                spotTimestamps: spotTimestamps,
                              ),
                              const SizedBox(height: 24),

                              // ── Prices info bar ──
                              _buildInfoBar(botState, currencyFormat),
                            ],
                          ),
                        ),
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
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════

  List<FlSpot> _buildBotRoiSpots(List<BotSnapshot> snapshots, double Function(BotSnapshot) roiExtractor) {
    return List.generate(snapshots.length, (i) => FlSpot(i.toDouble(), roiExtractor(snapshots[i]) * 100));
  }

  // ══════════════════════════════════════════════════════════════════
  //  CONFIG BUTTON
  // ══════════════════════════════════════════════════════════════════

  Widget _buildConfigButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showBotConfigDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: const Icon(Icons.tune_rounded, color: Colors.white54, size: 16),
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
          _buildInfoItem('1 WBTC', '${s.priceWbtcInWeth.toStringAsFixed(4)} WETH', Colors.white54, subtitle: 'Pool Price'),
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
//  BOT TOGGLE BUTTON
// ══════════════════════════════════════════════════════════════════

class _BotToggleButton extends StatefulWidget {
  @override
  State<_BotToggleButton> createState() => _BotToggleButtonState();
}

class _BotToggleButtonState extends State<_BotToggleButton> {
  bool _loading = false;

  Future<void> _toggle(bool currentEnabled) async {
    final newEnabled = !currentEnabled;
    final action = newEnabled ? 'ENCENDER' : 'APAGAR';
    final emoji = newEnabled ? '🟢' : '🔴';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$emoji $action Bot', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que querés ${action.toLowerCase()} el bot?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirmar', style: TextStyle(color: newEnabled ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final functions = locator<FundFunctionsService>();
      await functions.toggleBot(enabled: newEnabled);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();

    return StreamBuilder<bool>(
      stream: fundRepo.streamBotEnabled(),
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? false;
        final color = enabled ? AppColors.success : AppColors.error;

        return GestureDetector(
          onTap: _loading ? null : () => _toggle(enabled),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: _loading
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.power_settings_new_rounded, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        enabled ? 'ON' : 'OFF',
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
