import 'package:cloud_firestore/cloud_firestore.dart';
import 'bot_state.dart';

/// Snapshot diario del estado del bot.
///
/// Se almacena en `bot_snapshots/{date}`.
/// Extiende [BotState] y agrega [id] y [timestamp].
class BotSnapshot extends BotState {
  final String id;
  final DateTime? timestamp;

  BotSnapshot({
    required this.id,
    this.timestamp,
    required super.idleWeth,
    required super.idleWbtc,
    required super.feesWeth,
    required super.feesWbtc,
    required super.poolWeth,
    required super.poolWbtc,
    required super.totalWeth,
    required super.totalWbtc,
    required super.totalValueUsd,
    required super.initialWeth,
    required super.initialWbtc,
    required super.deltaWeth,
    required super.deltaWbtc,
    required super.pnlWeth,
    required super.pnlWbtc,
    required super.poolPriceWbtcInWeth,
    required super.hasActivePosition,
    required super.priceWeth,
    required super.priceWbtc,
    required super.pricePol,
    super.lastUpdateTimestamp,
  });

  factory BotSnapshot.fromMap(String id, Map<String, dynamic> data) {
    return BotSnapshot(
      id: id,
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null,
      idleWeth: (data['idle_weth'] ?? 0.0).toDouble(),
      idleWbtc: (data['idle_wbtc'] ?? 0.0).toDouble(),
      feesWeth: (data['fees_weth'] ?? 0.0).toDouble(),
      feesWbtc: (data['fees_wbtc'] ?? 0.0).toDouble(),
      poolWeth: (data['pool_weth'] ?? 0.0).toDouble(),
      poolWbtc: (data['pool_wbtc'] ?? 0.0).toDouble(),
      totalWeth: (data['total_weth'] ?? 0.0).toDouble(),
      totalWbtc: (data['total_wbtc'] ?? 0.0).toDouble(),
      totalValueUsd: (data['total_value_usd'] ?? 0.0).toDouble(),
      initialWeth: (data['initial_weth'] ?? 0.0).toDouble(),
      initialWbtc: (data['initial_wbtc'] ?? 0.0).toDouble(),
      deltaWeth: (data['delta_weth'] ?? 0.0).toDouble(),
      deltaWbtc: (data['delta_wbtc'] ?? 0.0).toDouble(),
      pnlWeth: (data['pnl_weth'] ?? 0.0).toDouble(),
      pnlWbtc: (data['pnl_wbtc'] ?? 0.0).toDouble(),
      poolPriceWbtcInWeth: (data['pool_price_wbtc_in_weth'] ?? 0.0).toDouble(),
      hasActivePosition: data['has_active_position'] ?? false,
      priceWeth: (data['price_weth'] ?? 0.0).toDouble(),
      priceWbtc: (data['price_wbtc'] ?? 0.0).toDouble(),
      pricePol: (data['price_pol'] ?? 0.0).toDouble(),
      lastUpdateTimestamp: data['last_update_timestamp'] != null
          ? (data['last_update_timestamp'] as Timestamp).toDate()
          : null,
    );
  }
}
