import 'package:cloud_firestore/cloud_firestore.dart';
import 'fund_state.dart';

class FundSnapshot extends FundState {
  final String id;
  final DateTime? timestamp;
  final double priceWeth;
  final double priceWbtc;
  final double balanceMaticWallet;
  final double balanceWethWallet;
  final double balanceWethPool;
  final double balanceWethTotal;
  final double balanceWbtcWallet;
  final double balanceWbtcPool;
  final double balanceWbtcTotal;

  FundSnapshot({
    required this.id,
    required super.navUsd,
    required super.navWeth,
    required super.navWbtc,
    required super.totalShares,
    required super.totalValueUsd,
    required super.totalValueWeth,
    required super.totalValueWbtc,
    required super.inventoryWeth,
    required super.inventoryWbtc,
    super.lastUpdateTimestamp,
    this.timestamp,
    required this.priceWeth,
    required this.priceWbtc,
    required this.balanceMaticWallet,
    required this.balanceWethWallet,
    required this.balanceWethPool,
    required this.balanceWethTotal,
    required this.balanceWbtcWallet,
    required this.balanceWbtcPool,
    required this.balanceWbtcTotal,
  });

  factory FundSnapshot.fromMap(String id, Map<String, dynamic> data) {
    return FundSnapshot(
      id: id,
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
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      priceWeth: (data['price_weth'] ?? 0.0).toDouble(),
      priceWbtc: (data['price_wbtc'] ?? 0.0).toDouble(),
      balanceMaticWallet: (data['balance_matic_wallet'] ?? 0.0).toDouble(),
      balanceWethWallet: (data['balance_weth_wallet'] ?? 0.0).toDouble(),
      balanceWethPool: (data['balance_weth_pool'] ?? 0.0).toDouble(),
      balanceWethTotal: (data['balance_weth_total'] ?? 0.0).toDouble(),
      balanceWbtcWallet: (data['balance_wbtc_wallet'] ?? 0.0).toDouble(),
      balanceWbtcPool: (data['balance_wbtc_pool'] ?? 0.0).toDouble(),
      balanceWbtcTotal: (data['balance_wbtc_total'] ?? 0.0).toDouble(),
    );
  }
}
