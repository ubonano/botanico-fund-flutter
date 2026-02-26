class FundConfig {
  final String walletAddress;

  FundConfig({required this.walletAddress});

  factory FundConfig.fromMap(Map<String, dynamic> map) {
    return FundConfig(walletAddress: map['walletAddress'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'walletAddress': walletAddress};
  }
}
