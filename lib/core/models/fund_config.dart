class FundConfig {
  final String walletAddress;
  final String fundInvestorId;

  FundConfig({required this.walletAddress, required this.fundInvestorId});

  factory FundConfig.fromMap(Map<String, dynamic> map) {
    return FundConfig(walletAddress: map['walletAddress'] ?? '', fundInvestorId: map['fundInvestorId'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'walletAddress': walletAddress, 'fundInvestorId': fundInvestorId};
  }
}
