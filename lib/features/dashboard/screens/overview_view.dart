import 'package:flutter/material.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/fund_state.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fund Overview',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              StreamBuilder<FundState?>(
                stream: fundRepo.streamCurrentFundState(),
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state == null) return const SizedBox();
                  return _buildHeaderBadge(
                    'Shares',
                    state.totalShares.toStringAsFixed(4),
                    Icons.pie_chart,
                    const Color(0xFF3B82F6),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<FundState?>(
              stream: fundRepo.streamCurrentFundState(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading fund state: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFF43F5E)),
                    ),
                  );
                }

                final fundState = snapshot.data;

                if (fundState == null) {
                  return const Center(
                    child: Text('No fund data available.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ROW 1: TOTAL VALUES
                      _buildSectionTitle('Total Value'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTokenCard(
                              title: 'USD Value',
                              value: '\$${fundState.totalValueUsd.toStringAsFixed(2)}',
                              icon: Icons.attach_money,
                              tokenColor: const Color(0xFF10B981), // Green for Fiat
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTokenCard(
                              title: 'WBTC Value',
                              value: fundState.totalValueWbtc.toStringAsFixed(8),
                              icon: Icons.currency_bitcoin,
                              tokenColor: const Color(0xFFF7931A), // Bitcoin Orange
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTokenCard(
                              title: 'WETH Value',
                              value: fundState.totalValueWeth.toStringAsFixed(8),
                              icon: Icons.currency_exchange,
                              tokenColor: const Color(0xFF627EEA), // Ethereum Blue
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ROW 2: INVENTORY
                      _buildSectionTitle('Inventory'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTokenCard(
                              title: 'USDT Inventory',
                              value: '0.00000000', // Hardcoded as requested
                              icon: Icons.payments,
                              tokenColor: const Color(0xFF26A17B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTokenCard(
                              title: 'WBTC Inventory',
                              value: '${fundState.inventoryWbtc.toStringAsFixed(8)}',
                              icon: Icons.inventory_2,
                              tokenColor: const Color(0xFFF7931A),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTokenCard(
                              title: 'WETH Inventory',
                              value: '${fundState.inventoryWeth.toStringAsFixed(8)}',
                              icon: Icons.inventory_2,
                              tokenColor: const Color(0xFF627EEA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ROW 3: NAV
                      _buildSectionTitle('Net Asset Value (NAV)'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNavCard(
                              title: 'NAV USD',
                              value: '\$${fundState.navUsd.toStringAsFixed(4)}',
                              tokenColor: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildNavCard(
                              title: 'NAV WBTC',
                              value: fundState.navWbtc.toStringAsFixed(8),
                              tokenColor: const Color(0xFFF7931A),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildNavCard(
                              title: 'NAV WETH',
                              value: fundState.navWeth.toStringAsFixed(8),
                              tokenColor: const Color(0xFF627EEA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildHeaderBadge(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenCard({
    required String title,
    required String value,
    required IconData icon,
    required Color tokenColor,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokenColor.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tokenColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: tokenColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: tokenColor.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard({required String title, required String value, required Color tokenColor}) {
    return Card(
      color: const Color(0xFF1E293B), // Slate 800
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tokenColor.withOpacity(0.5), width: 1.5),
      ),
      child: Stack(
        children: [
          // Background Gradient subtle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [tokenColor.withOpacity(0.15), Colors.transparent],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: tokenColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
