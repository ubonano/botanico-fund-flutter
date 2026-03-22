import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:botanico_fund_flutter/core/config/locator.dart';
import 'package:botanico_fund_flutter/core/services/auth_service.dart';
import 'package:botanico_fund_flutter/core/services/fund_repository.dart';
import 'package:botanico_fund_flutter/core/models/investor.dart';
import 'package:botanico_fund_flutter/core/models/investor_snapshot.dart';
import 'package:botanico_fund_flutter/core/models/operation.dart';
import 'package:botanico_fund_flutter/core/models/fund_state.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';
import 'package:botanico_fund_flutter/core/shared/token_card.dart';
import 'package:botanico_fund_flutter/features/dashboard/screens/capital_movement_dialog.dart';

/// Pantalla principal del inversor. Soporta dos modos:
/// - **Inversor**: muestra logo, bienvenida, token cards, logout.
/// - **Admin**: muestra nombre con gradient, cuotapartes/participación,
///   token cards, botón nuevo movimiento, sección de operaciones expandible.
class InvestorHomeScreen extends StatefulWidget {
  final String investorId;
  final bool isAdmin;

  const InvestorHomeScreen({
    super.key,
    required this.investorId,
    this.isAdmin = false,
  });

  @override
  State<InvestorHomeScreen> createState() => _InvestorHomeScreenState();
}

class _InvestorHomeScreenState extends State<InvestorHomeScreen> with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  bool _operationsExpanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  static const int _itemCount = 6;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnimations = List.generate(_itemCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.3).clamp(0.0, 1.0);
      return CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOut));
    });

    _slideAnimations = List.generate(_itemCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });

    _expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _expandAnimation = CurvedAnimation(parent: _expandController, curve: Curves.easeInOutCubic);

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleOperations() {
    setState(() {
      _operationsExpanded = !_operationsExpanded;
      if (_operationsExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        title: const Text('¿Cerrar sesión?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Se cerrará tu sesión actual.', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed == true) await locator<AuthService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final fundRepo = locator<FundRepository>();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final cryptoFormat = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 6);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: StreamBuilder<Investor?>(
        stream: fundRepo.streamInvestor(widget.investorId),
        builder: (context, investorSnap) {
          if (investorSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final investor = investorSnap.data;
          if (investor == null) {
            return const Center(
              child: Text('No se encontró información del inversor.', style: TextStyle(color: Colors.white54)),
            );
          }

          return StreamBuilder<FundState?>(
            stream: fundRepo.streamCurrentFundState(),
            builder: (context, fundSnap) {
              final fundState = fundSnap.data;
              final currentValueUsd = investor.currentShares * (fundState?.navUsd ?? 0.0);
              final currentValueWbtc = investor.currentShares * (fundState?.navWbtc ?? 0.0);
              final currentValueWeth = investor.currentShares * (fundState?.navWeth ?? 0.0);

              final variationUsd = currentValueUsd - investor.netInvestmentUsd;
              final variationWbtc = currentValueWbtc - investor.netInvestmentWbtc;
              final variationWeth = currentValueWeth - investor.netInvestmentWeth;

              final participation = fundState != null && fundState.totalShares > 0
                  ? (investor.currentShares / fundState.totalShares) * 100
                  : 0.0;

              return StreamBuilder<List<InvestorSnapshot>>(
                stream: fundRepo.streamInvestorSnapshots(widget.investorId),
                builder: (context, snapshotSnap) {
                  final snapshots = snapshotSnap.data ?? [];

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                            child: Column(
                              children: [
                                // ── Investor: Logo + Welcome ──
                                if (!widget.isAdmin) ...[
                                  _buildAnimated(0, _buildLogo()),
                                  const SizedBox(height: 6),
                                  _buildAnimated(1, _buildWelcome(investor)),
                                  const SizedBox(height: 28),
                                ],

                                // ── Admin: Name + Shares badge ──
                                if (widget.isAdmin) ...[
                                  _buildAnimated(0, _buildAdminWelcome(investor)),
                                  const SizedBox(height: 14),
                                  _buildAnimated(1, _buildSharesBadge(investor, participation)),
                                  const SizedBox(height: 24),
                                ],

                                // ── Token Cards ──
                                _buildAnimated(
                                  widget.isAdmin ? 2 : 2,
                                  TokenCard(
                                    tokenSymbol: 'WBTC',
                                    tokenIcon: '₿',
                                    tokenColor: const Color(0xFFF7931A),
                                    netInvestment: investor.netInvestmentWbtc,
                                    currentValue: currentValueWbtc,
                                    roi: investor.roiWbtc,
                                    nominalVariation: variationWbtc,
                                    formatValue: (v) => cryptoFormat.format(v),
                                    roiSpots: _buildRoiSpots(snapshots, (s) => s.roiWbtc),
                                    spotTimestamps: snapshots.map((s) => s.timestamp).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildAnimated(
                                  3,
                                  TokenCard(
                                    tokenSymbol: 'WETH',
                                    tokenIcon: 'Ξ',
                                    tokenColor: const Color(0xFF627EEA),
                                    netInvestment: investor.netInvestmentWeth,
                                    currentValue: currentValueWeth,
                                    roi: investor.roiWeth,
                                    nominalVariation: variationWeth,
                                    formatValue: (v) => cryptoFormat.format(v),
                                    roiSpots: _buildRoiSpots(snapshots, (s) => s.roiWeth),
                                    spotTimestamps: snapshots.map((s) => s.timestamp).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildAnimated(
                                  4,
                                  TokenCard(
                                    tokenSymbol: 'USD',
                                    tokenIcon: '\$',
                                    tokenColor: AppColors.primaryViolet,
                                    netInvestment: investor.netInvestmentUsd,
                                    currentValue: currentValueUsd,
                                    roi: investor.roiUsd,
                                    nominalVariation: variationUsd,
                                    formatValue: (v) => currencyFormat.format(v),
                                    roiSpots: _buildRoiSpots(snapshots, (s) => s.roiUsd),
                                    spotTimestamps: snapshots.map((s) => s.timestamp).toList(),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ── Admin: Movement button + Operations ──
                                if (widget.isAdmin) ...[
                                  _buildAnimated(5, _buildNewMovementButton(investor)),
                                  const SizedBox(height: 16),
                                  _buildOperationsSection(fundRepo, investor, currencyFormat),
                                  const SizedBox(height: 24),
                                ],

                                // ── Investor: Logout ──
                                if (!widget.isAdmin) ...[
                                  const SizedBox(height: 12),
                                  _buildLogoutButton(),
                                ],
                              ],
                            ),
                          ),

                          // ── Admin: Floating back button ──
                          if (widget.isAdmin)
                            Positioned(
                              top: 10,
                              left: 4,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDark.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white38, size: 16),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimated(int index, Widget child) {
    if (index >= _itemCount) return child;
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  // ── Logo ──
  Widget _buildLogo() {
    return Image.asset('assets/images/botanico_logo.png', width: 300, height: 300, fit: BoxFit.contain);
  }

  // ── Investor Welcome ──
  Widget _buildWelcome(Investor investor) {
    return Column(
      children: [
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Hola, ${investor.name}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.3),
          ),
        ),
        const SizedBox(height: 4),
        const Text('Estado de tu fondo', style: TextStyle(color: Colors.white30, fontSize: 13)),
      ],
    );
  }

  // ── Admin Welcome ──
  Widget _buildAdminWelcome(Investor investor) {
    final fullName = '${investor.name} ${investor.lastName}'.trim();
    return Column(
      children: [
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            fullName.isNotEmpty ? fullName : investor.id,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.3),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Detalle del inversor', style: TextStyle(color: Colors.white30, fontSize: 13)),
      ],
    );
  }

  // ── Shares / Participation Badge ──
  Widget _buildSharesBadge(Investor investor, double participation) {
    final sharesFormat = NumberFormat('#,##0.00', 'en_US');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 10),
          Text(
            sharesFormat.format(investor.currentShares),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'cuotapartes',
            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 20, color: AppColors.primary.withValues(alpha: 0.15)),
          const SizedBox(width: 16),
          Text(
            '${participation.toStringAsFixed(2)}%',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 6),
          Text(
            'del fondo',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── New Movement Button ──
  Widget _buildNewMovementButton(Investor investor) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {
          CapitalMovementDialog.show(
            context,
            investorId: investor.id,
            investorName: investor.name.isNotEmpty ? investor.name : investor.id,
            colorTheme: AppColors.primary,
          );
        },
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
        label: const Text(
          'Nuevo Movimiento',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Expandable Operations Section ──
  Widget _buildOperationsSection(FundRepository fundRepo, Investor investor, NumberFormat currencyFormat) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Column(
      children: [
        // Toggle header
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _toggleOperations,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: Colors.white.withValues(alpha: 0.35), size: 18),
                const SizedBox(width: 10),
                Text(
                  'HISTORIAL DE OPERACIONES',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) => Transform.rotate(
                    angle: _expandAnimation.value * 3.14159,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandable list
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildOperationsList(fundRepo, investor, currencyFormat, dateFormat),
            ),
          ),
        ),
      ],
    );
  }

  // ── Operations List ──
  Widget _buildOperationsList(
    FundRepository fundRepo,
    Investor investor,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return StreamBuilder<List<Operation>>(
      stream: fundRepo.streamInvestorOperations(investor.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
          );
        }

        final operations = snapshot.data;
        if (operations == null || operations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No hay operaciones registradas.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
              ),
            ),
          );
        }

        return Column(
          children: operations.map((op) {
            final style = _operationStyle(op.type);
            final displayAmount = switch (op.type) {
              'COMMISSION' => op.commissionUsd,
              'COMMISSION_INCOME' => op.totalCommissionUsd,
              _ => op.amountUsd,
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildOperationTile(op, style, displayAmount, currencyFormat, dateFormat),
            );
          }).toList(),
        );
      },
    );
  }

  static const _commissionAmber = Color(0xFFF59E0B);

  ({Color color, IconData icon, String label}) _operationStyle(String type) {
    return switch (type) {
      'DEPOSIT' => (color: AppColors.success, icon: Icons.arrow_downward_rounded, label: 'Depósito'),
      'WITHDRAWAL' => (color: AppColors.error, icon: Icons.arrow_upward_rounded, label: 'Retiro'),
      'COMMISSION' => (color: _commissionAmber, icon: Icons.percent_rounded, label: 'Comisión'),
      'COMMISSION_INCOME' => (
        color: AppColors.primaryCyan,
        icon: Icons.account_balance_rounded,
        label: 'Ingreso Comisión',
      ),
      _ => (color: Colors.white38, icon: Icons.help_outline, label: type),
    };
  }

  Widget _buildOperationTile(
    Operation op,
    ({Color color, IconData icon, String label}) style,
    double displayAmount,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.color.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(style.icon, color: style.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style.label,
                      style: TextStyle(color: style.color, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      currencyFormat.format(displayAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      op.timestamp != null ? dateFormat.format(op.timestamp!) : 'Fecha desconocida',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10),
                    ),
                    Text(
                      'NAV ${currencyFormat.format(op.navUsdApplied)}  ·  ${op.sharesOperated.toStringAsFixed(2)} cp',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
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

  // ── ROI Spots helper ──
  List<FlSpot> _buildRoiSpots(List<InvestorSnapshot> snapshots, double Function(InvestorSnapshot) extractor) {
    return List.generate(snapshots.length, (i) => FlSpot(i.toDouble(), extractor(snapshots[i]) * 100));
  }

  // ── Logout ──
  Widget _buildLogoutButton() {
    return SizedBox(
      width: 170,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 15),
        label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white30,
          side: const BorderSide(color: AppColors.borderDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
