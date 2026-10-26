import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'domain/pos_repository.dart';
import 'data/local_database.dart';

class UserManagementView extends ConsumerWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Initialize database if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(databaseProvider).valueOrNull?.customSelect('SELECT 1').get();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(authState.fullName ?? 'Owner', style: const TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tambah Karyawan',
            onPressed: () => _showAddUserDialog(context, ref),
          ),
        ],
      ),
      body: Row(
        children: [
          // Tab Bar
          _TabBar(),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              children: const [
                _StoreSettingsTab(),
                _FinancialTab(),
                _ExpenseEntryTab(),
                _ExpensePaymentTab(),
                _AddUserTab(),
                _InventoryTab(),
                _PaymentSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final usernameCtrl = TextEditingController();
    final fullNameCtrl = TextEditingController();
    final waCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'CASHIER');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Karyawan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: waCtrl,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            DropdownButtonFormField<String>(
              value: roleCtrl.text.isNotEmpty ? roleCtrl.text : 'CASHIER',
              decoration: const InputDecoration(labelText: 'Role'),
              items: [
                const DropdownMenuItem(value: 'OWNER', child: Text('OWNER')),
                const DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                const DropdownMenuItem(value: 'SUPERVISOR', child: Text('SUPERVISOR')),
                const DropdownMenuItem(value: 'CASHIER', child: Text('CASHIER')),
              ],
              onChanged: (value) {
                if (value != null) roleCtrl.text = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(posRepositoryProvider).createOwner(
                username: usernameCtrl.text,
                fullName: fullNameCtrl.text,
                password: 'admin12345',
                storeName: authState.username,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Karyawan berhasil ditambahkan')),
              );
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: TabBar(
        tabs: const [
          Tab(text: 'Pengaturan Toko'),
          Tab(text: 'Modal Awal'),
          Tab(text: 'Catat Pengeluaran'),
          Tab(text: 'Bayar Pengeluaran'),
          Tab(text: 'Tambah Karyawan'),
          Tab(text: 'Inventaris Toko'),
          Tab(text: 'Seting Pembayaran'),
        ],
        labelColor: Colors.blue.shade800,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.blue.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StoreSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store info card
          _StoreCard(),

          const SizedBox(height: 24),

          // Store name/logo
          _buildSettingRow(
            context,
            icon: Icons.store_outlined,
            label: 'Nama Toko',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          _buildSettingRow(
            context,
            icon: Icons.description_outlined,
            label: 'Slogan',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          _buildSettingRow(
            context,
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          _buildSettingRow(
            context,
            icon: Icons.chat_outlined,
            label: 'WhatsApp',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          const SizedBox(height: 24),

          // Logo upload
          _buildSettingRow(
            context,
            icon: Icons.image_outlined,
            label: 'Logo Toko',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          const SizedBox(height: 24),

          // Save button
          Center(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_alt),
              label: const Text('Simpan Pengaturan'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
      BuildContext context, IconData icon, String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F6FF), Color(0xFFD6ECFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.store, color: Colors.blue.shade700, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kasirin POS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Setiap kali mau ganti toko, klik ikon toko di atas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingRow(
            context,
            icon: Icons.insert_chart_outlined,
            label: 'Modal Awal Keuangan',
            trailing: const Text('Rp 0', style: TextStyle(color: Colors.green)),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            context,
            icon: Icons.check_box_outlined,
            label: 'Aktifkan Laporan Keuangan',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: Colors.green,
            ),
          ),
          const SizedBox(height: 24),

          // Expense entry section
          Text(
            'Catat Pengeluaran',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildExpenseForm(context),
        ],
      ),
    );
  }

  Widget _buildExpenseForm(BuildContext context) {
    final _accountCtrl = TextEditingController();
    final _payeeCtrl = TextEditingController();
    final _descriptionCtrl = TextEditingController();
    final _amountCtrl = TextEditingController();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _accountCtrl,
              decoration: const InputDecoration(
                labelText: 'Akun',
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _payeeCtrl,
              decoration: const InputDecoration(
                labelText: 'Payee / Penjual',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                suffixText: '+ DP',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Catat Pengeluaran'),
                  ),
                ),
                const Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.remove_circle_outline),
                    label: 'Batal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseEntryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengeluaran Dicatat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Expense list placeholder
          Text(
            'Belum ada pengeluaran tercatat',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ExpensePaymentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bayar Pengeluaran',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Payment list placeholder
          Text(
            'Belum ada pengeluaran yang perlu dibayar',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _AddUserTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Karyawan Baru',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Form untuk menambah karyawan baru dengan role sesuai hak akses.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventaris Toko',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Inventory list placeholder
          Text(
            'Belum ada data inventaris',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _PaymentSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seting Pembayaran Kasir',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodRow(
            context,
            icon: Icons.qr_code_2_outlined,
            label: 'DANA',
            status: 'active',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodRow(
            context,
            icon: Icons.payment_outlined,
            label: 'Midtrans',
            status: 'inactive',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodRow(
            context,
            Icons.menu_book_outlined,
            label: 'QRIS',
            status: 'active',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow(
      BuildContext context, IconData icon, String label, String status, VoidCallback onTap) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: status == 'active' ? Colors.green.shade50 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: status == 'active' ? Colors.green.shade700 : Colors.grey, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: status == 'active' ? FontWeight.bold : FontWeight.normal),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: status == 'active' ? Colors.green.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status == 'active' ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status == 'active' ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}