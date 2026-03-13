import 'package:cloud_firestore/cloud_firestore.dart';

/// Estado actual del bot de trading.
///
/// Se almacena en `bot_state/current`.
/// Contiene balances desglosados (idle/fees/pool), totales, PnL bimonetario,
/// deltas, precios y estado de la posición.
class BotState {
  // Componente 1: Balance líquido (tokens ociosos en el vault)
  final double idleWeth;
  final double idleWbtc;
  // Componente 2: Comisiones pendientes (uncollected fees del NFT)
  final double feesWeth;
  final double feesWbtc;
  // Componente 3: Liquidez activa en el pool
  final double poolWeth;
  final double poolWbtc;
  // Totales (idle + fees + pool)
  final double totalWeth;
  final double totalWbtc;
  final double totalValueUsd;
  // Base de comparación (se fija una vez)
  final double initialWeth;
  final double initialWbtc;
  // Deltas absolutos
  final double deltaWeth;
  final double deltaWbtc;
  // PnL bimonetario
  final double pnlWeth;
  final double pnlWbtc;
  // Precio del par desde el pool
  final double poolPriceWbtcInWeth;
  // Estado de la posición
  final bool hasActivePosition;
  // Precios USD (Chainlink)
  final double priceWeth;
  final double priceWbtc;
  final double pricePol;
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
    required this.totalValueUsd,
    required this.initialWeth,
    required this.initialWbtc,
    required this.deltaWeth,
    required this.deltaWbtc,
    required this.pnlWeth,
    required this.pnlWbtc,
    required this.poolPriceWbtcInWeth,
    required this.hasActivePosition,
    required this.priceWeth,
    required this.priceWbtc,
    required this.pricePol,
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
