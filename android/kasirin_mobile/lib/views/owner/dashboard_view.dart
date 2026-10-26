import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../cashier/cashier_view.dart';
import '../auth/auth_state.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierprovider);
    final isOwner = authState.role == 'OWNER';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isOwner ? 'Dashboard' : 'Kasir'),
        leading: isOwner ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/cashier'),
        ),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await ref.read(authNotifierprovider.notifier).logout();
                    if (context.mounted) {
                      GoRouter.of(context).go('/login');
                    }
                  },
                ),
              ]
            : null,
      ),
      body: isOwner ? _buildOwnerDashboard(context, ref) : const CashierView(),
    );
  }

  Widget _buildOwnerDashboard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierprovider);

    final menuItems = [
      DashboardMenuItem(
        icon: Icons.store_outlined,
        label: 'Manajemen Toko',
        subtitle: 'Pengaturan toko, karyawan, inventaris',
        color: Colors.blue.shade600,
        route: '/user-management',
      ),
      DashboardMenuItem(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        subtitle: 'Laporan penjualan, keuangan, stok',
        color: Colors.green.shade600,
        route: '/report-center',
      ),
      DashboardMenuItem(
        icon: Icons.inventory_2_outlined,
        label: 'Master Data',
        subtitle: 'Produk, kategori, satuan',
        color: Colors.orange.shade600,
        route: '/master-data',
      ),
      DashboardMenuItem(
        icon: Icons.shopping_cart_outlined,
        label: 'Belanja & Supplier',
        subtitle: 'Pembelian, supplier, hutang',
        color: Colors.purple.shade600,
        route: '/purchase',
      ),
      DashboardMenuItem(
        icon: Icons.credit_card_outlined,
        label: 'Aktivasi / Langganan',
        subtitle: 'Lisensi, pembayaran, tagihan',
        color: Colors.indigo.shade600,
        route: '/license',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              authState.fullName ?? 'Owner',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                authState.role ?? 'OWNER',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          size: 30,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Selamat datang kembali',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Akses Cepat',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _DashboardCard(
                item: item,
                onTap: () => GoRouter.of(context).go(item.route),
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Produk', value: '0', icon: Icons.inventory_2, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Penjualan Hari Ini', value: 'Rp 0', icon: Icons.attach_money, color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Shift Aktif', value: '0', icon: Icons.timer, color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardMenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final String route;

  DashboardMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}

class _DashboardCard extends StatelessWidget {
  final DashboardMenuItem item;
  final VoidCallback onTap;

  const _DashboardCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}