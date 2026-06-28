import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../services/mitra_api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;           // untuk keranjang (dibatasi stok)
  int _qtyPermintaan = 1; // untuk permintaan ke produsen (boleh melebihi stok)
  bool _isLoading = false;

  String _formatRp(int val) => 'Rp ${val.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

  // ✅ Validasi stok kosong sebelum lanjut
  bool get _isStokHabis => widget.product.stock <= 0;

  void _addToCart() {
    // ✅ Cek stok sebelum tambah ke keranjang
    if (_isStokHabis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk ini sedang habis'),
          backgroundColor: AppColors.deleteRed,
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    for (int i = 0; i < _qty; i++) {
      cart.addToCart(widget.product);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} x$_qty kg ditambahkan ke keranjang'),
        backgroundColor: AppColors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _requestToProdusen() async {
    // ✅ Cek stok sebelum kirim permintaan
    if (_isStokHabis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk ini sedang habis'),
          backgroundColor: AppColors.deleteRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gunakan _qtyPermintaan — boleh melebihi stok
    final result = await MitraApiService.buatPermintaan(
      idProduksi: widget.product.id,
      jumlah: _qtyPermintaan,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil! Permintaan ${widget.product.name} x$_qtyPermintaan kg dikirim ke produsen'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      // ✅ Tampilkan pesan error dari backend (termasuk "Stok tidak cukup" dari ProdusenController)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengirim permintaan'),
          backgroundColor: AppColors.deleteRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
                    child: Image.network(
                      p.image,
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 260,
                        color: const Color(0xFFE8E0D5),
                        child: const Icon(Icons.set_meal, size: 80, color: AppColors.iconGrey),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // ✅ Tampilkan label "Stok Habis" jika stok 0
                        Row(
                          children: [
                            Text(
                              _isStokHabis ? 'Stok Habis' : 'Stok Tersedia : ${p.stock} kg',
                              style: TextStyle(
                                color: _isStokHabis ? AppColors.deleteRed : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _isStokHabis ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            if (_isStokHabis) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.deleteRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Habis',
                                    style: TextStyle(
                                        color: AppColors.deleteRed,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        // ── Jumlah untuk Keranjang (dibatasi stok) ──
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isStokHabis
                                ? AppColors.bgCard.withOpacity(0.5)
                                : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Jumlah Beli (Kg)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: _isStokHabis ? null : () {
                                      if (_qty > 1) setState(() => _qty--);
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('$_qty Kg',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary)),
                                  ),
                                  _QtyBtn(
                                    icon: Icons.add,
                                    onTap: _isStokHabis ? null : () {
                                      if (_qty < p.stock) setState(() => _qty++);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ── Jumlah untuk Permintaan ke Produsen (bebas, boleh > stok) ──
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Jumlah Permintaan (Kg)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (_qtyPermintaan > 1) setState(() => _qtyPermintaan--);
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('$_qtyPermintaan Kg',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary)),
                                  ),
                                  _QtyBtn(
                                    icon: Icons.add,
                                    // Tidak ada batas maksimal
                                    onTap: () => setState(() => _qtyPermintaan++),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Harga per kg',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(_formatRp(p.price),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total harga',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(_formatRp(p.price * _qty),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blue)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatRp(p.price * _qty),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    Text('$_qty Kg dipilih',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          // ✅ Disable tombol jika stok habis atau loading
                          onPressed: (_isLoading || _isStokHabis) ? null : _requestToProdusen,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue),
                                )
                              : const Icon(Icons.send_outlined, size: 16),
                          label: Text(
                            _isLoading
                                ? 'Mengirim...'
                                : _isStokHabis
                                    ? 'Stok Habis'
                                    : 'Minta ke Produsen',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isStokHabis ? AppColors.iconGrey : AppColors.blue,
                            side: BorderSide(
                              color: _isStokHabis ? AppColors.iconGrey : AppColors.blue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          // ✅ Disable tombol jika stok habis
                          onPressed: (_isLoading || _isStokHabis) ? null : _addToCart,
                          icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                          label: Text(
                            _isStokHabis ? 'Stok Habis' : 'Tambah ke Keranjang',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isStokHabis ? AppColors.iconGrey : AppColors.blue,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
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
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // ✅ nullable agar bisa di-disable
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            // ✅ Warna abu jika disabled
            color: onTap == null
                ? AppColors.iconGrey.withOpacity(0.1)
                : AppColors.blue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: onTap == null ? AppColors.iconGrey : AppColors.blue,
            size: 18,
          ),
        ),
      );
}