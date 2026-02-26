class Operation {
  final String id;
  final String type; // "DEPOSIT" or "WITHDRAWAL"
  final DateTime? timestamp;
  final double amountUsd;
  final double amountWbtc;
  final double amountWeth;
  final double priceWbtc;
  final double priceWeth;
  final double navUsdApplied;
  final double sharesOperated;
  final double sharesBefore;
  final double sharesAfter;
  final double netUsdBefore;
  final double netUsdAfter;
  final double realizedPnlUsd;
  final double realizedPnlWbtc;
  final double realizedPnlWeth;

  Operation({
    required this.id,
    required this.type,
    this.timestamp,
    required this.amountUsd,
    required this.amountWbtc,
    required this.amountWeth,
    required this.priceWbtc,
    required this.priceWeth,
    required this.navUsdApplied,
    required this.sharesOperated,
    required this.sharesBefore,
    required this.sharesAfter,
    required this.netUsdBefore,
    required this.netUsdAfter,
    required this.realizedPnlUsd,
    required this.realizedPnlWbtc,
    required this.realizedPnlWeth,
  });

  factory Operation.fromMap(String id, Map<String, dynamic> data) {
    return Operation(
      id: id,
      type: data['type'] ?? '',
      timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null,
      amountUsd: (data['amount_usd'] ?? 0.0).toDouble(),
      amountWbtc: (data['amount_wbtc'] ?? 0.0).toDouble(),
      amountWeth: (data['amount_weth'] ?? 0.0).toDouble(),
      priceWbtc: (data['price_wbtc'] ?? 0.0).toDouble(),
      priceWeth: (data['price_weth'] ?? 0.0).toDouble(),
      navUsdApplied: (data['nav_usd_applied'] ?? 0.0).toDouble(),
      sharesOperated: (data['shares_operated'] ?? 0.0).toDouble(),
      sharesBefore: (data['shares_before'] ?? 0.0).toDouble(),
      sharesAfter: (data['shares_after'] ?? 0.0).toDouble(),
      netUsdBefore: (data['net_usd_before'] ?? 0.0).toDouble(),
      netUsdAfter: (data['net_usd_after'] ?? 0.0).toDouble(),
      realizedPnlUsd: (data['realized_pnl_usd'] ?? 0.0).toDouble(),
      realizedPnlWbtc: (data['realized_pnl_wbtc'] ?? 0.0).toDouble(),
      realizedPnlWeth: (data['realized_pnl_weth'] ?? 0.0).toDouble(),
    );
  }
}
