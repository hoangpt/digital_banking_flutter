import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_scanner_screen.dart';

class QrPanel extends StatefulWidget {
  final VoidCallback onGenerateQr;
  final VoidCallback onScanQr;
  const QrPanel({
    super.key,
    required this.onGenerateQr,
    required this.onScanQr,
  });

  @override
  State<QrPanel> createState() => _QrPanelState();
}

class _QrPanelState extends State<QrPanel> {
  bool isGenerateMode = true;
  final TextEditingController _amountController = TextEditingController();
  String? generatedQrData;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    // Generate default QR code without amount
    _generateDefaultQr();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _generateDefaultQr() {
    setState(() {
      // Standard banking QR format without amount
      generatedQrData = _createBankingQrData(null);
    });
  }

  void _generatePersonalQr() {
    final amount = _amountController.text.trim();

    setState(() {
      if (amount.isEmpty) {
        // Generate default QR without amount
        generatedQrData = _createBankingQrData(null);
      } else {
        // Generate QR with specific amount
        generatedQrData = _createBankingQrData(double.tryParse(amount));
      }
    });

    widget.onGenerateQr();

    if (amount.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code generated for \$$amount')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default QR Code generated')),
      );
    }
  }

  String _createBankingQrData(double? amount) {
    // Create a more realistic banking QR format
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final accountId = "123456789"; // Demo account ID
    final bankCode = "KLBANK"; // Demo bank code

    if (amount != null) {
      // QR with specific amount
      return "BANK:$bankCode|ACC:$accountId|AMT:${amount.toStringAsFixed(2)}|REF:$timestamp|DESC:Payment Request";
    } else {
      // General payment QR
      return "BANK:$bankCode|ACC:$accountId|AMT:OPEN|REF:$timestamp|DESC:Payment to Account";
    }
  }

  void _copyQrData() {
    if (generatedQrData != null) {
      Clipboard.setData(ClipboardData(text: generatedQrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR data copied to clipboard')),
      );
    }
  }

  Future<void> _openQrScanner() async {
    try {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
      );

      if (result != null) {
        setState(() {
          _scannedData = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code scanned successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error scanning QR: $e')));
    }
  }

  String _parseQrData(String qrData) {
    try {
      // Parse banking QR format: BANK:KLBANK|ACC:123456789|AMT:50.00|REF:timestamp|DESC:Payment Request
      if (qrData.startsWith('BANK:')) {
        final parts = qrData.split('|');
        String bank = '';
        String account = '';
        String amount = '';
        String description = '';

        for (final part in parts) {
          if (part.startsWith('BANK:')) {
            bank = part.substring(5);
          } else if (part.startsWith('ACC:')) {
            account = part.substring(4);
          } else if (part.startsWith('AMT:')) {
            amount = part.substring(4);
          } else if (part.startsWith('DESC:')) {
            description = part.substring(5);
          }
        }

        if (amount == 'OPEN') {
          return 'Bank: $bank\nAccount: $account\nAmount: Open (enter amount)\nDescription: $description';
        } else {
          return 'Bank: $bank\nAccount: $account\nAmount: \$$amount\nDescription: $description';
        }
      } else {
        // Generic QR code
        return 'QR Data: $qrData';
      }
    } catch (e) {
      return 'Invalid QR Code format';
    }
  }

  void _processScannedPayment(String qrData) {
    try {
      if (qrData.startsWith('BANK:')) {
        final parts = qrData.split('|');
        String amount = '';

        for (final part in parts) {
          if (part.startsWith('AMT:')) {
            amount = part.substring(4);
            break;
          }
        }

        if (amount == 'OPEN') {
          // Show amount input dialog for open amount QR
          _showAmountInputDialog();
        } else {
          // Process fixed amount payment
          _showPaymentConfirmation(amount);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported QR code format')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing payment: $e')));
    }
  }

  void _showAmountInputDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (\$)',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentConfirmation(amountController.text);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showPaymentConfirmation(String amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text('Send \$$amount to this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment of \$$amount sent successfully!'),
                ),
              );
              // Clear scanned data after processing
              setState(() {
                _scannedData = null;
              });
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModeButton(
                    icon: Icons.qr_code_2,
                    label: 'Generate',
                    isSelected: isGenerateMode,
                    onTap: () => setState(() => isGenerateMode = true),
                  ),
                  _ModeButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan',
                    isSelected: !isGenerateMode,
                    onTap: () => setState(() => isGenerateMode = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Icon
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                isGenerateMode ? Icons.qr_code_2 : Icons.qr_code_scanner,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isGenerateMode ? 'Generate QR Code' : 'Scan QR Code',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Text(
              isGenerateMode
                  ? 'Create a personal QR code for others to send you money.\nEnter the amount you want to receive.'
                  : 'Scan QR codes to send money to others.\nPoint your camera at any banking QR code.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (isGenerateMode) ...[
              // Always show QR Code first
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: [
                    // Real QR Code
                    if (generatedQrData != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: generatedQrData!,
                          version: QrVersions.auto,
                          size: 120.0,
                          backgroundColor: Colors.white,
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _amountController.text.trim().isEmpty
                          ? 'Personal QR Code'
                          : 'QR Code for \$${_amountController.text.trim()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: _copyQrData,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                        ),
                        TextButton.icon(
                          onPressed: _generateDefaultQr,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount input and generate button
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount to receive (optional)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  helperText: 'Leave empty for general payment QR',
                ),
                onChanged: (value) {
                  // Update QR display text when amount changes
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: _generatePersonalQr,
                icon: const Icon(Icons.qr_code_2),
                label: Text(
                  _amountController.text.trim().isEmpty
                      ? 'Generate Default QR'
                      : 'Generate QR with Amount',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ] else ...[
              // Scan Mode UI
              FilledButton.icon(
                onPressed: _openQrScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Open QR Scanner'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),

              if (_scannedData != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanned QR Code:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _parseQrData(_scannedData!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          // Process payment based on scanned data
                          _processScannedPayment(_scannedData!);
                        },
                        child: const Text('Process Payment'),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 16),
            Text(
              isGenerateMode
                  ? 'Your personal QR code is ready to share. Add amount for specific payments.'
                  : 'Demo: Scan merchant or personal QR codes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
