import 'package:cloud_firestore/cloud_firestore.dart';

class FundState {
  final double navUsd;
  final double navWeth;
  final double navWbtc;
  final double totalShares;
  final double totalValueUsd;
  final double totalValueWeth;
  final double totalValueWbtc;
  final double inventoryWeth;
  final double inventoryWbtc;
  final DateTime? lastUpdateTimestamp;

  FundState({
    required this.navUsd,
    required this.navWeth,
    required this.navWbtc,
    required this.totalShares,
    required this.totalValueUsd,
    required this.totalValueWeth,
    required this.totalValueWbtc,
    required this.inventoryWeth,
    required this.inventoryWbtc,
    this.lastUpdateTimestamp,
  });

  factory FundState.fromMap(Map<String, dynamic> data) {
    return FundState(
      navUsd: (data['nav_usd'] ?? 0.0).toDouble(),
      navWeth: (data['nav_weth'] ?? 0.0).toDouble(),
      navWbtc: (data['nav_wbtc'] ?? 0.0).toDouble(),
      totalShares: (data['total_shares'] ?? 0.0).toDouble(),
      totalValueUsd: (data['total_value_usd'] ?? 0.0).toDouble(),
      totalValueWeth: (data['total_value_weth'] ?? 0.0).toDouble(),
      totalValueWbtc: (data['total_value_wbtc'] ?? 0.0).toDouble(),
      inventoryWeth: (data['inventory_weth'] ?? 0.0).toDouble(),
      inventoryWbtc: (data['inventory_wbtc'] ?? 0.0).toDouble(),
      lastUpdateTimestamp: data['last_update_timestamp'] != null
          ? (data['last_update_timestamp'] as Timestamp).toDate()
          : null,
    );
  }
}
