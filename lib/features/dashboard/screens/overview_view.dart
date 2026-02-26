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
          const Text(
            'Fund Overview',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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

                return GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _buildMetricCard(
                      'Net Asset Value (USD)',
                      '\$${fundState.navUsd.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                    _buildMetricCard(
                      'Total Value (USD)',
                      '\$${fundState.totalValueUsd.toStringAsFixed(2)}',
                      Icons.account_balance,
                    ),
                    _buildMetricCard('Total Shares', fundState.totalShares.toStringAsFixed(2), Icons.pie_chart),
                    _buildMetricCard(
                      'NAV (WETH)',
                      '${fundState.navWeth.toStringAsFixed(4)} WETH',
                      Icons.currency_exchange,
                    ),
                    _buildMetricCard(
                      'Total Value (WETH)',
                      '${fundState.totalValueWeth.toStringAsFixed(4)} WETH',
                      Icons.account_balance_wallet,
                    ),
                    _buildMetricCard(
                      'Inventory (WETH)',
                      '${fundState.inventoryWeth.toStringAsFixed(4)} WETH',
                      Icons.inventory_2,
                    ),
                    _buildMetricCard(
                      'NAV (WBTC)',
                      '${fundState.navWbtc.toStringAsFixed(4)} WBTC',
                      Icons.currency_bitcoin,
                    ),
                    _buildMetricCard(
                      'Total Value (WBTC)',
                      '${fundState.totalValueWbtc.toStringAsFixed(4)} WBTC',
                      Icons.account_balance_wallet,
                    ),
                    _buildMetricCard(
                      'Inventory (WBTC)',
                      '${fundState.inventoryWbtc.toStringAsFixed(4)} WBTC',
                      Icons.inventory_2,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF10B981), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
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
}
