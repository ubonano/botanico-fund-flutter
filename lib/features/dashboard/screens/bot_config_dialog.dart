import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/locator.dart';
import '../../../core/services/fund_repository.dart';
import '../../../core/theme/app_colors.dart';

/// Metadata de cada campo de configuración del bot.
class _ConfigField {
  final String key;
  final String label;
  final String description;
  final String suffix;
  final bool isDouble;

  const _ConfigField({
    required this.key,
    required this.label,
    required this.description,
    this.suffix = '',
    this.isDouble = false,
  });
}

const _configFields = [
  _ConfigField(
    key: 'gridWidth',
    label: 'Grid Width',
    description: 'Ancho base del rango de liquidez en ticks.',
    suffix: 'ticks',
  ),
  _ConfigField(
    key: 'maxWidthMultiplier',
    label: 'Max Width Multiplier',
    description: 'Multiplicador máximo para el ancho dinámico del rango.',
    suffix: '×',
  ),
  _ConfigField(
    key: 'cooldownMinutes',
    label: 'Cooldown',
    description: 'Minutos de espera entre rebalanceos consecutivos.',
    suffix: 'min',
  ),
  _ConfigField(
    key: 'tickHistorySize',
    label: 'Tick History Size',
    description: 'Cantidad de ticks a conservar en el historial (ej: 120 × 2min = 4h).',
    suffix: 'ticks',
  ),
  _ConfigField(
    key: 'txWaitTimeoutMs',
    label: 'TX Wait Timeout',
    description: 'Timeout máximo para esperar confirmación de una transacción.',
    suffix: 'ms',
  ),
  _ConfigField(
    key: 'txDeadlineSeconds',
    label: 'TX Deadline',
    description: 'Deadline on-chain para que se ejecute la transacción.',
    suffix: 's',
  ),
  _ConfigField(
    key: 'slippageTolerance',
    label: 'Slippage Tolerance',
    description: 'Tolerancia de slippage (0.99 = 1%, 0.95 = 5%).',
    isDouble: true,
  ),
  _ConfigField(
    key: 'shrinkThreshold',
    label: 'Shrink Threshold',
    description: 'Umbral porcentual para achicar el rango (0.70 = 70%).',
    isDouble: true,
  ),
  _ConfigField(
    key: 'recenterMinTicks',
    label: 'Recenter Min Ticks',
    description: 'Desplazamiento mínimo (× TICK_SPACING) para recentrar la posición.',
    suffix: 'ticks',
  ),
  _ConfigField(
    key: 'minInjectionAmount',
    label: 'Min Injection Amount',
    description: 'Monto mínimo (raw) de tokens ociosos para inyectar al pool.',
  ),
  _ConfigField(
    key: 'minHistoryForVolatility',
    label: 'Min History for Volatility',
    description: 'Cantidad mínima de datapoints para calcular la volatilidad.',
    suffix: 'pts',
  ),
];

/// Muestra el diálogo de configuración del bot.
Future<void> showBotConfigDialog(BuildContext context) async {
  final fundRepo = locator<FundRepository>();

  // Leer la config actual una vez para poblar los campos
  final stream = fundRepo.streamBotConfig();
  final currentConfig = await stream.first;

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => _BotConfigDialog(currentConfig: currentConfig),
  );
}

class _BotConfigDialog extends StatefulWidget {
  final Map<String, dynamic> currentConfig;

  const _BotConfigDialog({required this.currentConfig});

  @override
  State<_BotConfigDialog> createState() => _BotConfigDialogState();
}

class _BotConfigDialogState extends State<_BotConfigDialog> {
  late final Map<String, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in _configFields)
        field.key: TextEditingController(
          text: widget.currentConfig[field.key]?.toString() ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updates = <String, dynamic>{};
      for (final field in _configFields) {
        final text = _controllers[field.key]!.text.trim();
        if (text.isEmpty) continue;

        if (field.isDouble) {
          final val = double.tryParse(text);
          if (val != null) updates[field.key] = val;
        } else {
          final val = int.tryParse(text);
          if (val != null) {
            updates[field.key] = val;
          } else {
            // Si no parsea como int, intentar como double
            final dVal = double.tryParse(text);
            if (dVal != null) updates[field.key] = dVal;
          }
        }
      }

      if (updates.isNotEmpty) {
        final fundRepo = locator<FundRepository>();
        await fundRepo.updateBotConfig(updates);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune_rounded, color: AppColors.primaryCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración del Bot',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Parámetros de la estrategia de liquidez',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
                  ),
                ],
              ),
            ),

            // Fields list
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shrinkWrap: true,
                itemCount: _configFields.length,
                separatorBuilder: (_, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final field = _configFields[index];
                  return _buildFieldTile(field);
                },
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan.withValues(alpha: 0.15),
                      foregroundColor: AppColors.primaryCyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryCyan))
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(_saving ? 'Guardando...' : 'Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldTile(_ConfigField field) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + suffix
          Row(
            children: [
              Text(
                field.label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              if (field.suffix.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    field.suffix,
                    style: TextStyle(color: AppColors.primaryCyan.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            field.description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, height: 1.3),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: TextField(
              controller: _controllers[field.key],
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
              keyboardType: TextInputType.numberWithOptions(decimal: field.isDouble),
              inputFormatters: field.isDouble
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
                  : [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primaryCyan.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
