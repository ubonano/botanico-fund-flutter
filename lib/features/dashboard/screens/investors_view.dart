import 'package:flutter/material.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/fund_state.dart';
import 'investor_detail_screen.dart';

class InvestorsView extends StatelessWidget {
  const InvestorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investors List',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Investor>>(
              stream: fundRepo.streamInvestors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading investors: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFF43F5E)),
                    ),
                  );
                }

                final investors = snapshot.data;

                if (investors == null || investors.isEmpty) {
                  return const Center(
                    child: Text('No investors found.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return StreamBuilder<FundState?>(
                  stream: fundRepo.streamCurrentFundState(),
                  builder: (context, stateSnapshot) {
                    final fundState = stateSnapshot.data;
                    final currentNavUsd = fundState?.navUsd ?? 0.0;

                    return ListView.separated(
                      itemCount: investors.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final investor = investors[index];
                        final currentValueUsd = investor.currentShares * currentNavUsd;
                        final pnlNetoUsd = currentValueUsd - investor.netInvestmentUsd;

                        return Card(
                          color: const Color(0xFF1E293B), // Slate 800
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFF334155), width: 1),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                              child: Text(
                                investor.name.isNotEmpty ? investor.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              investor.name.isNotEmpty ? investor.name : investor.id,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  _buildChip('Shares: ${investor.currentShares.toStringAsFixed(4)}'),
                                  _buildChip('Invested: \$${investor.netInvestmentUsd.toStringAsFixed(2)}'),
                                  if (currentNavUsd > 0)
                                    _buildChip(
                                      'PNL: ${pnlNetoUsd >= 0 ? '+' : ''}\$${pnlNetoUsd.toStringAsFixed(2)}',
                                      color: pnlNetoUsd >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                                    ),
                                  _buildChip(
                                    'ROI: ${(investor.roiUsd * 100).toStringAsFixed(2)}%',
                                    color: investor.roiUsd >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InvestorDetailScreen(investor: investor)),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, {Color color = Colors.white70}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slate 900
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
