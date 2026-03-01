import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/config/locator.dart';
import '../../../../core/services/fund_functions_service.dart';
import '../../../../core/theme/app_colors.dart';

class CapitalMovementDialog extends StatefulWidget {
  final String investorId;
  final String investorName;
  final Color colorTheme;

  const CapitalMovementDialog({
    super.key,
    required this.investorId,
    required this.investorName,
    required this.colorTheme,
  });

  static Future<void> show(
    BuildContext context, {
    required String investorId,
    required String investorName,
    required Color colorTheme,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CapitalMovementDialog(investorId: investorId, investorName: investorName, colorTheme: colorTheme),
    );
  }

  @override
  State<CapitalMovementDialog> createState() => _CapitalMovementDialogState();
}

class _CapitalMovementDialogState extends State<CapitalMovementDialog> {
  final _amountController = TextEditingController();
  String _selectedType = 'DEPOSIT';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorMessage = 'Ingresá un monto.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'El monto debe ser un número mayor a 0.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final service = locator<FundFunctionsService>();
      final result = await service.processCapitalMovement(
        investorId: widget.investorId,
        type: _selectedType,
        amountUsd: amount,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = result;
      });

      // Cerrar automáticamente después de 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Error al procesar el movimiento.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = _selectedType == 'DEPOSIT';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.surfaceDark, AppColors.backgroundDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.colorTheme.withValues(alpha: 0.2), width: 1.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 40, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle Deposit/Withdrawal
                  _buildTypeToggle(),
                  const SizedBox(height: 20),

                  // Amount input
                  _buildAmountInput(),
                  const SizedBox(height: 20),

                  // Error / Success messages
                  if (_errorMessage != null) _buildMessage(_errorMessage!, AppColors.error),
                  if (_successMessage != null) _buildMessage(_successMessage!, AppColors.success),
                  if (_errorMessage != null || _successMessage != null) const SizedBox(height: 16),

                  // Confirm button
                  _buildConfirmButton(isDeposit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.colorTheme.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.swap_vert_rounded, color: widget.colorTheme, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo Movimiento',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(widget.investorName, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _isLoading ? null : () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: Colors.white38, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleOption('DEPOSIT', 'Depósito', Icons.arrow_downward, AppColors.success)),
          Expanded(child: _buildToggleOption('WITHDRAWAL', 'Retiro', Icons.arrow_upward, AppColors.error)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => setState(() {
              _selectedType = type;
              _errorMessage = null;
            }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.white24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white38,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Text(
            '\$',
            style: TextStyle(
              color: widget.colorTheme.withValues(alpha: 0.6),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _amountController,
              enabled: !_isLoading,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.15),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Text(
            'USD',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConfirmButton(bool isDeposit) {
    final color = isDeposit ? AppColors.success : AppColors.error;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading || _successMessage != null ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.03),
          disabledForegroundColor: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: color, strokeWidth: 2))
            : Text(
                isDeposit ? 'Confirmar Depósito' : 'Confirmar Retiro',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
