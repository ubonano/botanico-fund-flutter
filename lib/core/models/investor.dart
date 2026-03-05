class Investor {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final double currentShares;
  final double netInvestmentUsd;
  final double netInvestmentWbtc;
  final double netInvestmentWeth;
  final double avgPurchaseNavUsd;
  final double avgPurchaseNavWbtc;
  final double avgPurchaseNavWeth;
  final double roiUsd;
  final double roiWbtc;
  final double roiWeth;
  final double totalRealizedPnlUsd;
  final double totalRealizedPnlWbtc;
  final double totalRealizedPnlWeth;
  final double commissionRate;

  Investor({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.currentShares,
    required this.netInvestmentUsd,
    required this.netInvestmentWbtc,
    required this.netInvestmentWeth,
    required this.avgPurchaseNavUsd,
    required this.avgPurchaseNavWbtc,
    required this.avgPurchaseNavWeth,
    required this.roiUsd,
    required this.roiWbtc,
    required this.roiWeth,
    required this.totalRealizedPnlUsd,
    required this.totalRealizedPnlWbtc,
    required this.totalRealizedPnlWeth,
    required this.commissionRate,
  });

  factory Investor.fromMap(String id, Map<String, dynamic> data) {
    return Investor(
      id: id,
      name: data['name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'] ?? '',
      currentShares: (data['current_shares'] ?? 0.0).toDouble(),
      netInvestmentUsd: (data['net_investment_usd'] ?? 0.0).toDouble(),
      netInvestmentWbtc: (data['net_investment_wbtc'] ?? 0.0).toDouble(),
      netInvestmentWeth: (data['net_investment_weth'] ?? 0.0).toDouble(),
      avgPurchaseNavUsd: (data['avg_purchase_nav_usd'] ?? 0.0).toDouble(),
      avgPurchaseNavWbtc: (data['avg_purchase_nav_wbtc'] ?? 0.0).toDouble(),
      avgPurchaseNavWeth: (data['avg_purchase_nav_weth'] ?? 0.0).toDouble(),
      roiUsd: (data['roi_usd'] ?? 0.0).toDouble(),
      roiWbtc: (data['roi_wbtc'] ?? 0.0).toDouble(),
      roiWeth: (data['roi_weth'] ?? 0.0).toDouble(),
      totalRealizedPnlUsd: (data['total_realized_pnl_usd'] ?? 0.0).toDouble(),
      totalRealizedPnlWbtc: (data['total_realized_pnl_wbtc'] ?? 0.0).toDouble(),
      totalRealizedPnlWeth: (data['total_realized_pnl_weth'] ?? 0.0).toDouble(),
      commissionRate: (data['commission_rate'] ?? 0.0).toDouble(),
    );
  }
}
