import 'package:cloud_firestore/cloud_firestore.dart';

/// Snapshot diario del estado de un inversor individual.
///
/// Se almacena en `investors/{investorId}/snapshots/{docId}`.
/// Contiene todos los valores del inversor en el momento del snapshot.
class InvestorSnapshot {
  final String id;
  final DateTime? timestamp;
  final double avgPurchaseNavUsd;
  final double avgPurchaseNavWbtc;
  final double avgPurchaseNavWeth;
  final double currentShares;
  final double netInvestmentUsd;
  final double netInvestmentWbtc;
  final double netInvestmentWeth;
  final double roiUsd;
  final double roiWbtc;
  final double roiWeth;
  final double totalRealizedPnlUsd;
  final double totalRealizedPnlWbtc;
  final double totalRealizedPnlWeth;
  final double totalValueUsd;
  final double totalValueWbtc;
  final double totalValueWeth;

  InvestorSnapshot({
    required this.id,
    this.timestamp,
    required this.avgPurchaseNavUsd,
    required this.avgPurchaseNavWbtc,
    required this.avgPurchaseNavWeth,
    required this.currentShares,
    required this.netInvestmentUsd,
    required this.netInvestmentWbtc,
    required this.netInvestmentWeth,
    required this.roiUsd,
    required this.roiWbtc,
    required this.roiWeth,
    required this.totalRealizedPnlUsd,
    required this.totalRealizedPnlWbtc,
    required this.totalRealizedPnlWeth,
    required this.totalValueUsd,
    required this.totalValueWbtc,
    required this.totalValueWeth,
  });

  factory InvestorSnapshot.fromMap(String id, Map<String, dynamic> data) {
    return InvestorSnapshot(
      id: id,
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null,
      avgPurchaseNavUsd: (data['avg_purchase_nav_usd'] ?? 0.0).toDouble(),
      avgPurchaseNavWbtc: (data['avg_purchase_nav_wbtc'] ?? 0.0).toDouble(),
      avgPurchaseNavWeth: (data['avg_purchase_nav_weth'] ?? 0.0).toDouble(),
      currentShares: (data['current_shares'] ?? 0.0).toDouble(),
      netInvestmentUsd: (data['net_investment_usd'] ?? 0.0).toDouble(),
      netInvestmentWbtc: (data['net_investment_wbtc'] ?? 0.0).toDouble(),
      netInvestmentWeth: (data['net_investment_weth'] ?? 0.0).toDouble(),
      roiUsd: (data['roi_usd'] ?? 0.0).toDouble(),
      roiWbtc: (data['roi_wbtc'] ?? 0.0).toDouble(),
      roiWeth: (data['roi_weth'] ?? 0.0).toDouble(),
      totalRealizedPnlUsd: (data['total_realized_pnl_usd'] ?? 0.0).toDouble(),
      totalRealizedPnlWbtc: (data['total_realized_pnl_wbtc'] ?? 0.0).toDouble(),
      totalRealizedPnlWeth: (data['total_realized_pnl_weth'] ?? 0.0).toDouble(),
      totalValueUsd: (data['total_value_usd'] ?? 0.0).toDouble(),
      totalValueWbtc: (data['total_value_wbtc'] ?? 0.0).toDouble(),
      totalValueWeth: (data['total_value_weth'] ?? 0.0).toDouble(),
    );
  }
}
