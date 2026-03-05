import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/locator.dart';
import '../../../core/models/investor.dart';
import '../../../core/models/fund_config.dart';
import '../../../core/services/fund_repository.dart';
import '../../../core/theme/app_colors.dart';
import 'create_investor_dialog.dart';

class InvestorsScreen extends StatelessWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = locator<FundRepository>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.people_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inversores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text('Gestión de personas registradas', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
              _buildAddButton(context),
            ],
          ),
          const SizedBox(height: 24),

          // List
          Expanded(
            child: StreamBuilder<FundConfig?>(
              stream: repository.streamFundConfig(),
              builder: (context, configSnapshot) {
                final fundInvestorId = configSnapshot.data?.fundInvestorId ?? '';

                return StreamBuilder<List<Investor>>(
                  stream: repository.streamInvestors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar inversores',
                          style: TextStyle(color: AppColors.error.withValues(alpha: 0.8), fontSize: 14),
                        ),
                      );
                    }

                    final investors = snapshot.data ?? [];

                    if (investors.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.separated(
                      itemCount: investors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final investor = investors[index];
                        final isFundInvestor = fundInvestorId.isNotEmpty && investor.id == fundInvestorId;
                        return _buildInvestorTile(context, investor, isFundInvestor: isFundInvestor);
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

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => CreateInvestorDialog.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Nuevo Inversor',
              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, color: Colors.white.withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 16),
          Text(
            'No hay inversores registrados',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Creá el primer inversor con el botón de arriba',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorTile(BuildContext context, Investor investor, {required bool isFundInvestor}) {
    final fullName = '${investor.name} ${investor.lastName}'.trim();
    final initials = _getInitials(investor.name, investor.lastName);
    final isVip = investor.commissionRate == 0;
    final commissionPercent = (investor.commissionRate * 100).toStringAsFixed(0);

    // Colors for fund investor
    final tileColor = isFundInvestor ? AppColors.primaryCyan.withValues(alpha: 0.04) : AppColors.surfaceDark;
    final tileBorderColor = isFundInvestor ? AppColors.primaryCyan.withValues(alpha: 0.25) : AppColors.borderDark;
    final avatarAccent = isFundInvestor ? AppColors.primaryCyan : AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showInvestorDetailDialog(context, investor, isFundInvestor: isFundInvestor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tileBorderColor),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: avatarAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: avatarAccent.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: isFundInvestor
                    ? Icon(Icons.account_balance, color: avatarAccent, size: 18)
                    : Text(
                        initials,
                        style: TextStyle(color: avatarAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Name & Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fullName.isNotEmpty ? fullName : investor.id,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isFundInvestor) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.25)),
                          ),
                          child: const Text(
                            'FONDO',
                            style: TextStyle(
                              color: AppColors.primaryCyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (investor.email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(investor.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                  ],
                ],
              ),
            ),

            // Commission badge / VIP (no mostrar para inversor del fondo)
            if (!isFundInvestor && isVip)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryCyan.withValues(alpha: 0.15),
                      AppColors.primaryMagenta.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryViolet.withValues(alpha: 0.3)),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'VIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              )
            else if (!isFundInvestor)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Text(
                  '$commissionPercent%',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),

            // ID badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                investor.id.length > 8 ? '${investor.id.substring(0, 8)}…' : investor.id,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.15), size: 20),
          ],
        ),
      ),
    );
  }

  void _showInvestorDetailDialog(BuildContext context, Investor investor, {required bool isFundInvestor}) {
    final nameController = TextEditingController(text: investor.name);
    final lastNameController = TextEditingController(text: investor.lastName);
    final commissionController = TextEditingController(text: (investor.commissionRate * 100).toStringAsFixed(2));
    final commissionEnabled = !isFundInvestor;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF18181B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF27272A)),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(investor.name, investor.lastName),
                        style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${investor.name} ${investor.lastName}'.trim(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          investor.email,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Color(0xFF27272A)),
                    const SizedBox(height: 16),

                    // Nombre
                    _buildFieldLabel('Nombre'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: nameController,
                      hint: 'Nombre',
                      enabled: !isSaving,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Apellido
                    _buildFieldLabel('Apellido'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: lastNameController,
                      hint: 'Apellido',
                      enabled: !isSaving,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Comisión
                    _buildFieldLabel(isFundInvestor ? 'Comisión (%) — No editable' : 'Comisión (%)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commissionController,
                      enabled: commissionEnabled && !isSaving,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Colors.white24),
                        suffixText: '%',
                        suffixStyle: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF09090B),
                        prefixIcon: Icon(Icons.percent, color: Colors.white.withValues(alpha: 0.2), size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF27272A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF27272A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text('Cancelar', style: TextStyle(color: isSaving ? Colors.white12 : Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            final commissionPercent = double.tryParse(commissionController.text) ?? 0.0;
                            final commissionDecimal = commissionPercent / 100;

                            await locator<FundRepository>().updateInvestor(investor.id, {
                              'name': nameController.text.trim(),
                              'last_name': lastNameController.text.trim(),
                              'commission_rate': commissionDecimal,
                            });

                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Inversor actualizado correctamente'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al actualizar: $e'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF09090B),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.2), size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF27272A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF27272A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  String _getInitials(String name, String lastName) {
    final first = name.isNotEmpty ? name[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.isNotEmpty ? '$first$last' : '?';
  }
}
