import 'package:flutter/material.dart';
import 'package:botanico_fund_flutter/core/config/locator.dart';
import 'package:botanico_fund_flutter/core/services/fund_repository.dart';
import 'package:botanico_fund_flutter/core/services/fund_functions_service.dart';
import 'package:botanico_fund_flutter/core/models/fund_config.dart';
import 'package:botanico_fund_flutter/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _walletController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _hasChanges = false;
  String _originalWallet = '';

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  void _onConfigLoaded(FundConfig config) {
    if (!_hasChanges) {
      _originalWallet = config.walletAddress;
      if (_walletController.text != config.walletAddress) {
        _walletController.text = config.walletAddress;
      }
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await locator<FundFunctionsService>().updateWallet(walletAddress: _walletController.text.trim());

      if (mounted) {
        setState(() {
          _hasChanges = false;
          _originalWallet = _walletController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Configuración guardada correctamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FundConfig?>(
      stream: locator<FundRepository>().streamFundConfig(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _onConfigLoaded(snapshot.data!);
        }

        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Configuración',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Administra los parámetros del fondo',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Wallet Config Card
                _buildConfigCard(
                  title: 'Wallet del Fondo',
                  icon: Icons.account_balance_wallet_outlined,
                  description: 'Dirección de la wallet utilizada para las operaciones del fondo en la red.',
                  isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wallet Address Field
                        const Text(
                          'Wallet Address',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _walletController,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: '0x...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: AppColors.backgroundDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.borderDark),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.borderDark),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: const Icon(Icons.tag, color: Colors.white24, size: 18),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La dirección de wallet es requerida';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _hasChanges = value.trim() != _originalWallet;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _hasChanges ? 1.0 : 0.4,
                            child: ElevatedButton.icon(
                              onPressed: _hasChanges && !_isSaving ? _saveConfig : null,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDark),
                                    )
                                  : const Icon(Icons.save_rounded, size: 18),
                              label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.backgroundDark,
                                disabledBackgroundColor: AppColors.primaryGold.withOpacity(0.3),
                                disabledForegroundColor: AppColors.backgroundDark.withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigCard({
    required String title,
    required IconData icon,
    required String description,
    required Widget child,
    bool isLoading = false,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: AppColors.primaryGold, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(description, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: AppColors.borderDark),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2),
                    ),
                  )
                : child,
          ),
        ],
      ),
    );
  }
}
