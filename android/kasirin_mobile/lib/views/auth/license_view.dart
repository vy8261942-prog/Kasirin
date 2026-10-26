import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LicenseView extends StatefulWidget {
  const LicenseView({super.key});

  @override
  State<LicenseView> createState() => _LicenseViewState();
}

class _LicenseViewState extends State<LicenseView> {
  final _installationIdController = TextEditingController();
  bool _isLoading = false;
  String? _licenseStatus;
  bool _isReadOnly = false;

  @override
  void dispose() {
    _installationIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lisensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/login'),
        ),
        actions: [
          IconButton(
            icon: Icon(_isReadOnly ? Icons.edit : Icons.preview),
            tooltip: _isReadOnly ? 'Edit' : 'Read-Only',
            onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              color: _licenseStatus == null
                  ? Colors.grey.shade50
                  : (_licenseStatus == 'active' ? Colors.green.shade50 : Colors.red.shade50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      _licenseStatus == null ? Icons.help_outline : (_licenseStatus == 'trial' ? Icons.timer : Icons.verified_user),
                      size: 36,
                      color: _licenseStatus == null ? Colors.grey : (_licenseStatus == 'trial' ? Colors.orange : Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _licenseStatus?.capitalize ?? 'Tidak Aktif',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _licenseStatus == null ? Colors.grey.shade700 : Colors.blue,
                            ),
                          ),
                          if (_licenseStatus != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Aplikasi dalam ${_licenseStatus == 'trial' ? 'mode uji coba' : 'inaktiv'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                              ),
                            ),
                          ] else
                            Text(
                              'Login untuk mengaktifkan lisensi',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.key, color: Colors.blue.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Masukkan ID Instalasi',
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _installationIdController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan ID instalasi kamu',
                      prefixIcon: Icon(Icons.key_outlined, color: Colors.blue.shade700),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _activate(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Aktifkan', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              color: Colors.orange.shade50,
              child: ListTile(
                leading: Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                title: const Text('Mode Uji Coba'),
                subtitle: Text(
                  'Aktivasi lisensi perpanjangan atau pengujian fungsi di titik penjualan.',
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activate(BuildContext context) async {
    final installationId = _installationIdController.text.trim();
    if (installationId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _licenseStatus = null;
    });

    try {
      setState(() => _licenseStatus = 'trial');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lisensi uji coba aktif')),
        );
        GoRouter.of(context).go('/');
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

extension Capitalize on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}