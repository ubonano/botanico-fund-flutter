import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_repository.dart';
import '../../../../core/models/fund_snapshot.dart';
import '../../../../core/models/investor.dart';
import '../../../../core/models/fund_state.dart';
import '../../../../core/theme/app_colors.dart';
import 'investor_detail_screen.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final numberFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);
    final cryptoFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 4);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Visión global y métricas',
                    style: TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              StreamBuilder<FundSnapshot?>(
                stream: fundRepo.streamLatestSnapshot(),
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state == null) return const SizedBox();
                  return _buildHeaderBadge(
                    'Cuotapartes Totales',
                    numberFormat.format(state.totalShares),
                    Icons.pie_chart_sharp,
                    AppColors.primaryGold,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<FundSnapshot?>(
              stream: fundRepo.streamLatestSnapshot(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error cargando el fondo: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                final fundState = snapshot.data;

                if (fundState == null) {
                  return const Center(
                    child: Text('No hay información del fondo.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HERO SECTION: Total Value USD, NAV & Exposure
                      _buildHeroCard(
                        title: 'Valor Total del Fondo (USD)',
                        value: currencyFormat.format(fundState.totalValueUsd),
                        navTitle: 'NAV USD',
                        navValue: currencyFormat.format(fundState.navUsd),
                        wbtcExposure: cryptoFormat.format(fundState.totalValueWbtc),
                        wethExposure: cryptoFormat.format(fundState.totalValueWeth),
                        icon: Icons.account_balance_wallet,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(height: 24),

                      // DISTRIBUTION BAR
                      _buildDistributionBar(
                        wbtcValue: fundState.inventoryWbtc * fundState.priceWbtc,
                        wethValue: fundState.inventoryWeth * fundState.priceWeth,
                        usdtValue: 0,
                        polValue: 0,
                        currencyFormat: currencyFormat,
                      ),
                      const SizedBox(height: 28),

                      // ROW 2: ASSETS BREAKDOWN
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Activos en Tesorería',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildAssetCard(
                              title: 'Bitcoin',
                              subtitle: 'WBTC',
                              inventory: cryptoFormat.format(fundState.inventoryWbtc),
                              inventoryValueUsd: fundState.inventoryWbtc * fundState.priceWbtc,
                              price: currencyFormat.format(fundState.priceWbtc),
                              wallet: cryptoFormat.format(fundState.balanceWbtcWallet),
                              pool: cryptoFormat.format(fundState.balanceWbtcPool),
                              icon: Icons.currency_bitcoin,
                              color: const Color(0xFFF7931A),
                              currencyFormat: currencyFormat,
                            ),
                            const SizedBox(width: 16),
                            _buildAssetCard(
                              title: 'Ethereum',
                              subtitle: 'WETH',
                              inventory: cryptoFormat.format(fundState.inventoryWeth),
                              inventoryValueUsd: fundState.inventoryWeth * fundState.priceWeth,
                              price: currencyFormat.format(fundState.priceWeth),
                              wallet: cryptoFormat.format(fundState.balanceWethWallet),
                              pool: cryptoFormat.format(fundState.balanceWethPool),
                              icon: Icons.currency_exchange,
                              color: const Color(0xFF627EEA),
                              currencyFormat: currencyFormat,
                            ),
                            const SizedBox(width: 16),
                            _buildAssetCard(
                              title: 'Tether',
                              subtitle: 'USDT',
                              inventory: cryptoFormat.format(fundState.balanceUsdtWallet),
                              inventoryValueUsd: fundState.balanceUsdtWallet,
                              price: null,
                              wallet: cryptoFormat.format(fundState.balanceUsdtWallet),
                              pool: null,
                              icon: Icons.payments,
                              color: const Color(0xFF26A17B),
                              currencyFormat: currencyFormat,
                            ),
                            const SizedBox(width: 16),
                            _buildAssetCard(
                              title: 'Polygon',
                              subtitle: 'POL',
                              inventory: cryptoFormat.format(fundState.balancePolWallet),
                              inventoryValueUsd: fundState.balancePolWallet * fundState.pricePol,
                              price: currencyFormat.format(fundState.pricePol),
                              wallet: cryptoFormat.format(fundState.balancePolWallet),
                              pool: null,
                              icon: Icons.hexagon,
                              color: const Color(0xFF8247E5),
                              currencyFormat: currencyFormat,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // INVESTORS SECTION
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Inversores',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      StreamBuilder<List<Investor>>(
                        stream: fundRepo.streamInvestors(),
                        builder: (context, investorsSnapshot) {
                          if (investorsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: AppColors.primaryGold),
                              ),
                            );
                          }

                          if (investorsSnapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error cargando inversores: ${investorsSnapshot.error}',
                                style: const TextStyle(color: AppColors.error),
                              ),
                            );
                          }

                          final investors = investorsSnapshot.data;

                          if (investors == null || investors.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No se encontraron inversores.', style: TextStyle(color: Colors.white54)),
                              ),
                            );
                          }

                          return StreamBuilder<FundState?>(
                            stream: fundRepo.streamCurrentFundState(),
                            builder: (context, stateSnapshot) {
                              final investorFundState = stateSnapshot.data;
                              final currentNavUsd = investorFundState?.navUsd ?? 0.0;
                              final colors = AppColors.chartColors;

                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: investors.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final investor = entry.value;
                                  final currentValueUsd = investor.currentShares * currentNavUsd;
                                  final pnlNetoUsd = currentValueUsd - investor.netInvestmentUsd;
                                  final colorTheme = colors[index % colors.length];
                                  final participation = investorFundState != null && investorFundState.totalShares > 0
                                      ? (investor.currentShares / investorFundState.totalShares) * 100
                                      : 0.0;

                                  return _buildInvestorCard(
                                    context: context,
                                    investor: investor,
                                    currentValueUsd: currentValueUsd,
                                    pnlNetoUsd: pnlNetoUsd,
                                    participation: participation,
                                    colorTheme: colorTheme,
                                    currencyFormat: currencyFormat,
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
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

  Widget _buildHeaderBadge(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.borderDark, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String title,
    required String value,
    required String navTitle,
    required String navValue,
    required String wbtcExposure,
    required String wethExposure,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: color.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    navTitle.toUpperCase(),
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    navValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildExposureItem('WBTC', wbtcExposure, const Color(0xFFF7931A)),
              _buildExposureItem('WETH', wethExposure, const Color(0xFF627EEA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExposureItem(String token, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EQUIV. $token',
          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDistributionBar({
    required double wbtcValue,
    required double wethValue,
    required double usdtValue,
    required double polValue,
    required NumberFormat currencyFormat,
  }) {
    final total = wbtcValue + wethValue + usdtValue + polValue;
    if (total == 0) return const SizedBox();

    final segments = <_BarSegment>[
      _BarSegment('WBTC', wbtcValue, const Color(0xFFF7931A)),
      _BarSegment('WETH', wethValue, const Color(0xFF627EEA)),
      _BarSegment('USDT', usdtValue, const Color(0xFF26A17B)),
      _BarSegment('POL', polValue, const Color(0xFF8247E5)),
    ].where((s) => s.value > 0).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISTRIBUCIÓN DEL FONDO',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          // The bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 32,
              child: Row(
                children: segments.asMap().entries.map((entry) {
                  final seg = entry.value;
                  final fraction = seg.value / total;
                  return Expanded(
                    flex: (fraction * 1000).round(),
                    child: Container(
                      color: seg.color,
                      child: Center(
                        child: fraction > 0.08
                            ? Text(
                                '${(fraction * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: segments.map((seg) {
              final fraction = seg.value / total;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: seg.color, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${seg.label}  ',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyFormat.format(seg.value),
                    style: TextStyle(
                      color: seg.color.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '  (${(fraction * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard({
    required String title,
    required String subtitle,
    required String inventory,
    required double inventoryValueUsd,
    required String? price,
    required String? wallet,
    required String? pool,
    required IconData icon,
    required Color color,
    required NumberFormat currencyFormat,
  }) {
    final valueUsdFormatted = currencyFormat.format(inventoryValueUsd);

    return Container(
      width: 440,
      height: 297,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.0),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 8))],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceDark, AppColors.backgroundDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HEADER: Icono/Nombre + Precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (price != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'PRECIO',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),

          // MIDDLE: Desglose Wallet / Pool
          if (wallet != null || pool != null)
            Row(
              children: [
                if (wallet != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: Colors.white38, size: 14),
                          const SizedBox(width: 6),
                          const Text(
                            'WALLET',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            wallet,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (wallet != null && pool != null) const SizedBox(width: 10),
                if (pool != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop_outlined, color: color.withValues(alpha: 0.6), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'POOL',
                            style: TextStyle(
                              color: color.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            pool,
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          else
            const SizedBox(height: 38),

          // BOTTOM: Inventario + Valor USD en fila con fondo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Inventario en tokens
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INVENTARIO',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inventory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Valor total USD
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'VALOR TOTAL',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valueUsdFormatted,
                      style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorCard({
    required BuildContext context,
    required Investor investor,
    required double currentValueUsd,
    required double pnlNetoUsd,
    required double participation,
    required Color colorTheme,
    required NumberFormat currencyFormat,
  }) {
    final isPositive = pnlNetoUsd >= 0;
    final pnlColor = isPositive ? AppColors.success : AppColors.error;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        InvestorDetailDialog.show(context, investor: investor, colorTheme: colorTheme);
      },
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceDark, AppColors.backgroundDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorTheme.withValues(alpha: 0.15), width: 1.0),
          boxShadow: [BoxShadow(color: colorTheme.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Avatar + Nombre + Participación
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorTheme.withValues(alpha: 0.3), colorTheme.withValues(alpha: 0.1)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: colorTheme.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      investor.name.isNotEmpty ? investor.name[0].toUpperCase() : '?',
                      style: TextStyle(color: colorTheme, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.name.isNotEmpty ? investor.name : investor.id,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: colorTheme, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${participation.toStringAsFixed(2)}% del fondo',
                            style: TextStyle(
                              color: colorTheme.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 16),
              ],
            ),
            const SizedBox(height: 18),

            // BODY: Valor Actual + Rendimiento unificado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorTheme.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorTheme.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Valor actual
                  const Text(
                    'VALOR ACTUAL',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(currentValueUsd),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  // Divider sutil
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                  const SizedBox(height: 10),
                  // PNL + ROI en una sola fila
                  Row(
                    children: [
                      Icon(isPositive ? Icons.trending_up : Icons.trending_down, size: 18, color: pnlColor),
                      const SizedBox(width: 8),
                      Text(
                        '${isPositive ? '+' : ''}${currencyFormat.format(pnlNetoUsd)}',
                        style: TextStyle(
                          color: pnlColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ROI',
                        style: TextStyle(
                          color: pnlColor.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${isPositive ? '+' : ''}${(investor.roiUsd * 100).toStringAsFixed(2)}%',
                        style: TextStyle(color: pnlColor, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
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

class _BarSegment {
  final String label;
  final double value;
  final Color color;
  const _BarSegment(this.label, this.value, this.color);
}
