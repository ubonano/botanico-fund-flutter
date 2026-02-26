import 'package:flutter/material.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/operation.dart';

class InvestorDetailScreen extends StatelessWidget {
  final Investor investor;

  const InvestorDetailScreen({super.key, required this.investor});

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(investor.name.isNotEmpty ? investor.name : investor.id),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Investor Summary
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFF334155))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Shares', investor.currentShares.toStringAsFixed(4)),
                  _buildSummaryRow('Net USD', '\$${investor.netInvestmentUsd.toStringAsFixed(2)}'),
                  _buildSummaryRow(
                    'ROI',
                    '${(investor.roiUsd * 100).toStringAsFixed(2)}%',
                    color: investor.roiUsd >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                  ),
                  _buildSummaryRow('Avg Nav USD', '\$${investor.avgPurchaseNavUsd.toStringAsFixed(2)}'),
                  const Divider(color: Color(0xFF334155), height: 32),
                  const Text('Realized PNL', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'USD',
                    '\$${investor.totalRealizedPnlUsd.toStringAsFixed(2)}',
                    color: investor.totalRealizedPnlUsd >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                  ),
                  _buildSummaryRow('WBTC', investor.totalRealizedPnlWbtc.toStringAsFixed(5)),
                  _buildSummaryRow('WETH', investor.totalRealizedPnlWeth.toStringAsFixed(5)),
                ],
              ),
            ),
          ),
          // Right Panel: Operations List
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Operations History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<List<Operation>>(
                      stream: fundRepo.streamInvestorOperations(investor.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFF43F5E))),
                          );
                        }

                        final operations = snapshot.data;

                        if (operations == null || operations.isEmpty) {
                          return const Center(
                            child: Text('No operations found.', style: TextStyle(color: Colors.white54)),
                          );
                        }

                        return ListView.separated(
                          itemCount: operations.length,
                          separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155)),
                          itemBuilder: (context, index) {
                            final op = operations[index];
                            final isDeposit = op.type == 'DEPOSIT';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDeposit
                                    ? const Color(0xFF10B981).withOpacity(0.2)
                                    : const Color(0xFFF43F5E).withOpacity(0.2),
                                child: Icon(
                                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isDeposit ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                                ),
                              ),
                              title: Text(
                                '${isDeposit ? 'Deposit' : 'Withdrawal'} \$${op.amountUsd.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                op.timestamp != null ? op.timestamp.toString() : 'Unknown date',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'NAV: \$${op.navUsdApplied.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  Text(
                                    '${op.sharesOperated.toStringAsFixed(2)} Shares',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
