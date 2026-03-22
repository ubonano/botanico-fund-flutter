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
    required super.initialWeth,
    required super.initialWbtc,
    required super.initialPriceWeth,
    required super.initialPriceWbtc,
    required super.initialValueUsd,
    required super.initialValueWeth,
    required super.initialValueWbtc,
    required super.totalValueUsd,
    required super.totalValueWbtc,
    required super.totalValueWeth,
    required super.roiUsd,
    required super.roiWbtc,
    required super.roiWeth,
    required super.priceWeth,
    required super.priceWbtc,
    required super.pricePol,
    required super.priceWbtcInWeth,
    required super.hasActivePosition,
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
      initialWeth: (data['initial_weth'] ?? 0.0).toDouble(),
      initialWbtc: (data['initial_wbtc'] ?? 0.0).toDouble(),
      initialPriceWeth: (data['initial_price_weth'] ?? 0.0).toDouble(),
      initialPriceWbtc: (data['initial_price_wbtc'] ?? 0.0).toDouble(),
      initialValueUsd: (data['initial_value_usd'] ?? 0.0).toDouble(),
      initialValueWeth: (data['initial_value_weth'] ?? 0.0).toDouble(),
      initialValueWbtc: (data['initial_value_wbtc'] ?? 0.0).toDouble(),
      totalValueUsd: (data['total_value_usd'] ?? 0.0).toDouble(),
      totalValueWbtc: (data['total_value_wbtc'] ?? 0.0).toDouble(),
      totalValueWeth: (data['total_value_weth'] ?? 0.0).toDouble(),
      roiUsd: (data['roi_usd'] ?? 0.0).toDouble(),
      roiWbtc: (data['roi_wbtc'] ?? 0.0).toDouble(),
      roiWeth: (data['roi_weth'] ?? 0.0).toDouble(),
      priceWeth: (data['price_weth'] ?? 0.0).toDouble(),
      priceWbtc: (data['price_wbtc'] ?? 0.0).toDouble(),
      pricePol: (data['price_pol'] ?? 0.0).toDouble(),
      priceWbtcInWeth: (data['price_wbtc_in_weth'] ?? data['pool_price_wbtc_in_weth'] ?? 0.0).toDouble(),
      hasActivePosition: data['has_active_position'] ?? false,
      lastUpdateTimestamp: data['last_update_timestamp'] != null
          ? (data['last_update_timestamp'] as Timestamp).toDate()
          : null,
    );
  }
}
