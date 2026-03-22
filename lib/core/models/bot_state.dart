import 'package:cloud_firestore/cloud_firestore.dart';

/// Estado actual del bot de trading.
///
/// Se almacena en `bot_state/current`.
/// Contiene inventario desglosado (idle/fees/pool), valores iniciales congelados,
/// valores actuales, ROI trimonetario, precios y estado de la posición.
class BotState {
  // Inventario desglosado
  final double idleWeth;
  final double idleWbtc;
  final double feesWeth;
  final double feesWbtc;
  final double poolWeth;
  final double poolWbtc;
  final double totalWeth;
  final double totalWbtc;

  // Valores iniciales congelados
  final double initialWeth;
  final double initialWbtc;
  final double initialPriceWeth;
  final double initialPriceWbtc;
  final double initialValueUsd;
  final double initialValueWeth;
  final double initialValueWbtc;

  // Valores actuales (toda la posición convertida)
  final double totalValueUsd;
  final double totalValueWbtc;
  final double totalValueWeth;

  // ROI trimonetario
  final double roiUsd;
  final double roiWbtc;
  final double roiWeth;

  // Precios de mercado
  final double priceWeth;
  final double priceWbtc;
  final double pricePol;
  final double priceWbtcInWeth;

  // Estado de la posición
  final bool hasActivePosition;
  final DateTime? lastUpdateTimestamp;

  BotState({
    required this.idleWeth,
    required this.idleWbtc,
    required this.feesWeth,
    required this.feesWbtc,
    required this.poolWeth,
    required this.poolWbtc,
    required this.totalWeth,
    required this.totalWbtc,
    required this.initialWeth,
    required this.initialWbtc,
    required this.initialPriceWeth,
    required this.initialPriceWbtc,
    required this.initialValueUsd,
    required this.initialValueWeth,
    required this.initialValueWbtc,
    required this.totalValueUsd,
    required this.totalValueWbtc,
    required this.totalValueWeth,
    required this.roiUsd,
    required this.roiWbtc,
    required this.roiWeth,
    required this.priceWeth,
    required this.priceWbtc,
    required this.pricePol,
    required this.priceWbtcInWeth,
    required this.hasActivePosition,
    this.lastUpdateTimestamp,
  });

  factory BotState.fromMap(Map<String, dynamic> data) {
    return BotState(
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
