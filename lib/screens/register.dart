import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/mitra_api_service.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _roleDaftar = 'mitra';

  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _alamatCtrl      = TextEditingController(); // ← tambah alamat untuk mitra

  final _namaUsahaCtrl   = TextEditingController();
  final _alamatUsahaCtrl = TextEditingController();
  final _nomorNIBCtrl    = TextEditingController();
  final _deskripsiCtrl   = TextEditingController();
  String _jenisUsaha     = 'Nelayan';

  final _jenisUsahaList = ['Nelayan', 'Budidaya', 'Pengolahan'];

  bool _obscure        = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _alamatCtrl.dispose();
    _namaUsahaCtrl.dispose();
    _alamatUsahaCtrl.dispose();
    _nomorNIBCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerMitra() async {
    setState(() {
      _errorMsg  = null;
      _isLoading = true;
    });

    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() {
        _errorMsg  = 'Nama, email, dan password wajib diisi';
        _isLoading = false;
      });
      return;
    }

    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() {
        _errorMsg  = 'Password tidak sama';
        _isLoading = false;
      });
      return;
    }

    if (_passCtrl.text.length < 6) {
      setState(() {
        _errorMsg  = 'Password minimal 6 karakter';
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await MitraApiService.registerMitra(
        nama:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(), // ← ini jadi Username di backend
        noHp:     _phoneCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Akun berhasil dibuat!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      } else {
        setState(() => _errorMsg = result['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ajukanProdusen() async {
    setState(() => _errorMsg = null);

    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Nama lengkap wajib diisi');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Nomor WhatsApp wajib diisi');
      return;
    }
    if (_namaUsahaCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Nama usaha wajib diisi');
      return;
    }
    if (_alamatUsahaCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Alamat usaha wajib diisi');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Email wajib diisi');
      return;
    }

    const String nomorAdmin = '6289503787668';

    final String pesan = '''
*PENGAJUAN PENDAFTARAN PRODUSEN*
Aplikasi Rempang Eco City

━━━━━━━━━━━━━━━━━
*DATA PRIBADI*
Nama Lengkap : ${_nameCtrl.text.trim()}
No. WhatsApp : ${_phoneCtrl.text.trim()}
Email        : ${_emailCtrl.text.trim()}

━━━━━━━━━━━━━━━━━
*DATA USAHA*
Nama Usaha   : ${_namaUsahaCtrl.text.trim()}
Jenis Usaha  : $_jenisUsaha
Alamat Usaha : ${_alamatUsahaCtrl.text.trim()}
Nomor NIB    : ${_nomorNIBCtrl.text.trim().isEmpty ? '-' : _nomorNIBCtrl.text.trim()}
Deskripsi    : ${_deskripsiCtrl.text.trim().isEmpty ? '-' : _deskripsiCtrl.text.trim()}

━━━━━━━━━━━━━━━━━
Mohon verifikasi data saya dan buatkan akun produsen.
Terima kasih.
''';

    final String url =
        'https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(pesan)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFFDFDFD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Pendaftaran Diajukan!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: const Text(
            'Data pendaftaran kamu sudah dikirim ke admin via WhatsApp.\n\n'
            'Admin akan memverifikasi data kamu dan mengirimkan '
            'email serta password untuk login.\n\n'
            'Mohon tunggu konfirmasi dari admin.',
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _errorMsg =
          'Tidak bisa membuka WhatsApp. Pastikan WhatsApp sudah terinstall.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppLogo(height: 32, white: false),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Daftar Sebagai',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Pilih jenis akun yang ingin kamu daftarkan',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),

              Row(children: [
                _RoleCard(
                  icon: Icons.store_outlined,
                  label: 'Mitra Hilir',
                  desc: 'Pembeli produk laut',
                  selected: _roleDaftar == 'mitra',
                  onTap: () => setState(() => _roleDaftar = 'mitra'),
                ),
                const SizedBox(width: 12),
                _RoleCard(
                  icon: Icons.set_meal_outlined,
                  label: 'Produsen',
                  desc: 'Nelayan / KUB',
                  selected: _roleDaftar == 'produsen',
                  onTap: () => setState(() => _roleDaftar = 'produsen'),
                ),
              ]),
              const SizedBox(height: 24),

              if (_roleDaftar == 'produsen')
                _infoBanner(
                  icon: Icons.info_outline,
                  color: AppColors.successGreen,
                  text: 'Pendaftaran produsen memerlukan verifikasi admin. '
                      'Setelah mengajukan, admin akan menghubungi kamu via '
                      'WhatsApp untuk memberikan akun login.',
                ),

              if (_roleDaftar == 'mitra')
                _infoBanner(
                  icon: Icons.check_circle_outline,
                  color: AppColors.blue,
                  text: 'Akun Mitra Hilir langsung aktif setelah mendaftar. '
                      'Kamu bisa langsung login dan memesan produk.',
                ),

              const SizedBox(height: 24),

              // ── Form Mitra ──────────────────────────────────
              if (_roleDaftar == 'mitra') ...[
                _buildLabel('Nama Lengkap *'),
                const SizedBox(height: 6),
                _buildTextField(_nameCtrl, 'Masukkan nama lengkap', Icons.person_outline),
                const SizedBox(height: 14),
                _buildLabel('Username (Email) *'),
                const SizedBox(height: 6),
                _buildTextField(_emailCtrl, 'Masukkan email', Icons.email_outlined,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _buildLabel('Nomor Telepon'),
                const SizedBox(height: 6),
                _buildTextField(_phoneCtrl, 'Masukkan nomor telepon', Icons.phone_outlined,
                    type: TextInputType.phone),
                const SizedBox(height: 14),
                _buildLabel('Alamat *'),
                const SizedBox(height: 6),
                TextField(
                  controller: _alamatCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat lengkap',
                    hintStyle: TextStyle(color: AppColors.iconGrey, fontSize: 14),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(Icons.location_on_outlined, color: AppColors.iconGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildLabel('Password *'),
                const SizedBox(height: 6),
                _buildPasswordField(_passCtrl, 'Minimal 6 karakter',
                    _obscure, () => setState(() => _obscure = !_obscure)),
                const SizedBox(height: 14),
                _buildLabel('Konfirmasi Password *'),
                const SizedBox(height: 6),
                _buildPasswordField(_confirmPassCtrl, 'Ulangi password',
                    _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
              ],

              // ── Form Produsen ────────────────────────────────
              if (_roleDaftar == 'produsen') ...[
                _sectionTitle('Data Pribadi'),
                const SizedBox(height: 12),
                _buildLabel('Nama Lengkap *'),
                const SizedBox(height: 6),
                _buildTextField(_nameCtrl, 'Masukkan nama lengkap', Icons.person_outline),
                const SizedBox(height: 14),
                _buildLabel('Nomor WhatsApp *'),
                const SizedBox(height: 6),
                _buildTextField(_phoneCtrl, 'Contoh: 08123456789', Icons.phone_outlined,
                    type: TextInputType.phone),
                const SizedBox(height: 14),
                _buildLabel('Email *'),
                const SizedBox(height: 6),
                _buildTextField(_emailCtrl, 'Masukkan email aktif', Icons.email_outlined,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 24),
                _sectionTitle('Data Usaha'),
                const SizedBox(height: 12),
                _buildLabel('Nama Usaha / KUB *'),
                const SizedBox(height: 6),
                _buildTextField(_namaUsahaCtrl, 'Contoh: KUB Nelayan Rempang',
                    Icons.business_outlined),
                const SizedBox(height: 14),
                _buildLabel('Jenis Usaha *'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _jenisUsaha,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      items: _jenisUsahaList
                          .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                          .toList(),
                      onChanged: (v) => setState(() => _jenisUsaha = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildLabel('Alamat Usaha *'),
                const SizedBox(height: 6),
                TextField(
                  controller: _alamatUsahaCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat lengkap usaha',
                    hintStyle: TextStyle(color: AppColors.iconGrey, fontSize: 14),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.location_on_outlined, color: AppColors.iconGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildLabel('Nomor NIB (opsional)'),
                const SizedBox(height: 6),
                _buildTextField(_nomorNIBCtrl, 'Nomor Induk Berusaha (jika ada)',
                    Icons.badge_outlined, type: TextInputType.number),
                const SizedBox(height: 14),
                _buildLabel('Deskripsi Usaha (opsional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _deskripsiCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan tentang usaha kamu, jenis produk yang dijual, dll.',
                    hintStyle: TextStyle(color: AppColors.iconGrey, fontSize: 13),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.notes_outlined, color: AppColors.iconGrey),
                    ),
                  ),
                ),
              ],

              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.deleteRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.deleteRed.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.deleteRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMsg!,
                          style: const TextStyle(color: AppColors.deleteRed, fontSize: 13)),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : (_roleDaftar == 'mitra' ? _registerMitra : _ajukanProdusen),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          _roleDaftar == 'mitra'
                              ? Icons.check_circle_outline
                              : Icons.send_outlined,
                          size: 18,
                        ),
                  label: Text(
                    _isLoading
                        ? 'Memproses...'
                        : (_roleDaftar == 'mitra' ? 'Daftar Sekarang' : 'Ajukan Pendaftaran'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleDaftar == 'mitra'
                        ? AppColors.blue
                        : AppColors.successGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? ',
                      style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Masuk',
                        style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required Color color,
    required String text,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: color, height: 1.4)),
          ),
        ]),
      );

  Widget _sectionTitle(String title) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Container(height: 2, width: 40, color: AppColors.successGreen),
        ],
      );

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
      );

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.iconGrey, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.iconGrey),
        ),
      );

  Widget _buildPasswordField(
    TextEditingController ctrl,
    String hint,
    bool obscure,
    VoidCallback toggle,
  ) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.iconGrey, fontSize: 14),
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconGrey),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.iconGrey,
            ),
            onPressed: toggle,
          ),
        ),
      );
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.successGreen.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.successGreen : const Color(0xFFE0E0E0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon,
                size: 28,
                color: selected ? AppColors.successGreen : AppColors.iconGrey),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.successGreen : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(desc,
                style: TextStyle(
                    fontSize: 11,
                    color: selected ? AppColors.successGreen : AppColors.textSecondary),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}