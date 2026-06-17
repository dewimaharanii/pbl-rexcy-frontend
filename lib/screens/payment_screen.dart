import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Tambahan untuk ambil gambar
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../services/mitra_api_service.dart';
import 'home_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _namaLengkap;
  String? _nomorTelepon;
  String? _alamat;
  String? _detailAlamat;

  // State untuk unggah bukti menggunakan image_picker
  XFile? _buktiTransfer;
  bool _isLoadingPayment = false;

  String _formatRp(int val) => 'Rp ${val.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

  void _showAddressForm() {
    final namaCtrl = TextEditingController(text: _namaLengkap);
    final phoneCtrl = TextEditingController(text: _nomorTelepon);
    final alamatCtrl = TextEditingController(text: _alamat);
    final detailCtrl = TextEditingController(text: _detailAlamat);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Tambah Alamat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              _buildInputLabel('Nama Lengkap'),
              _buildTextField(namaCtrl, 'Masukkan nama'),
              const SizedBox(height: 16),
              _buildInputLabel('Nomor Telepon'),
              _buildTextField(phoneCtrl, 'Masukkan nomor telepon', isNumber: true),
              const SizedBox(height: 16),
              _buildInputLabel('Alamat'),
              _buildTextField(alamatCtrl, 'Masukkan alamat lengkap'),
              const SizedBox(height: 16),
              _buildInputLabel('Detail alamat (opsional)'),
              _buildTextField(detailCtrl, 'Patokan, blok, dll'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _namaLengkap = namaCtrl.text;
                      _nomorTelepon = phoneCtrl.text;
                      _alamat = alamatCtrl.text;
                      _detailAlamat = detailCtrl.text;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SIMPAN',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: AppColors.bgPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Fungsi untuk mengambil gambar dari Galeri Device
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _buktiTransfer = image;
      });
    }
  }

  // Fungsi Eksekusi Pembayaran ke Backend
  Future<void> _prosesPembayaran(CartProvider cart) async {
    setState(() => _isLoadingPayment = true);

    try {
      // Loop semua item di keranjang dan buat transaksinya di backend
      for (var item in cart.items) {
        await MitraApiService.buatTransaksi(
          idProduksi: item.product.id,
          jumlah: item.qty,
          totalHarga: item.product.price * item.qty,
          catatan: 'Kirim ke: $_namaLengkap, $_alamat ($_nomorTelepon)',
        );
      }

      // Jika berhasil, kosongkan keranjang
      if (mounted) {
        context.read<CartProvider>().clearCart();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.deleteRed,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPayment = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Pembayaran berhasil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Pindah ke DashboardMitra (Akan mereset history)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('KEMBALI KE BERANDA',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text('Bayar Sekarang',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  children: [
                    // --- CARD ALAMAT ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: _namaLengkap == null || _namaLengkap!.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: _showAddressForm,
                                  icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 18),
                                  label: const Text('Tambah Alamat',
                                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$_namaLengkap ($_nomorTelepon)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    GestureDetector(
                                      onTap: _showAddressForm,
                                      child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.blue),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('$_alamat${_detailAlamat != null && _detailAlamat!.isNotEmpty ? ', $_detailAlamat' : ''}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                    ),

                    const SizedBox(height: 20),

                    // --- CARD PEMBAYARAN BNI ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BNI',
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Transfer ke No. Rekening :',
                                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    SizedBox(height: 4),
                                    Text('1307270301',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Menampilkan nama file gambar asli
                          _buktiTransfer != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgPrimary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.image, size: 16, color: AppColors.iconGrey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_buktiTransfer!.name, 
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () => setState(() => _buktiTransfer = null),
                                        child: const Icon(Icons.close, size: 16, color: AppColors.deleteRed),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.blue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12)
                                    ),
                                    child: const Text('UNGGAH BUKTI TRANSFER',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // --- BAGIAN BAWAH (TOTAL & BAYAR SEKARANG) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Column(
              children: [
                Text('Total Belanja : ${_formatRp(cart.totalPrice)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_namaLengkap != null && _buktiTransfer != null && !_isLoadingPayment)
                        ? () => _prosesPembayaran(cart)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      disabledBackgroundColor: AppColors.iconGrey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoadingPayment 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('BAYAR SEKARANG',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}