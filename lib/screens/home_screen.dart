import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../services/mitra_api_service.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';

// --- BAGIAN 1: HomeScreen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    CartScreen(),
    HistoryScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// --- BAGIAN 2: HomeContent ---
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedCategory = 'Ikan';
  String _searchQuery      = '';
  final _searchCtrl        = TextEditingController();
  final List<String> _categories = ['Ikan', 'Udang', 'Cumi'];

  List<ProductModel> _allProducts = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduk() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await MitraApiService.getProduk();
    if (!mounted) return;
    if (result['success'] == true) {
      final List list = result['data'];
      setState(() {
       _allProducts = list.map((e) => ProductModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMsg  = 'Gagal memuat produk';
        _isLoading = false;
      });
    }
  }

List<ProductModel> get _filtered {
    return _allProducts.where((p) {
      // 1. Filter berdasarkan pencarian (teks)
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Filter berdasarkan kategori yang dipilih
      // Kita asumsikan kata "Ikan", "Udang", atau "Cumi" ada di dalam nama produknya
      // (contoh: "Ikan - Kakap", "Udang - Tiger")
      final matchCategory = p.name.toLowerCase().contains(_selectedCategory.toLowerCase());

      // Tampilkan produk HANYA JIKA cocok dengan pencarian DAN kategorinya
      return matchSearch && matchCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  Row(children: [
                    const AppLogo(height: 36, white: false),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.iconGrey),
                      onPressed: _loadProduk,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Cari produk...',
                            hintStyle: TextStyle(color: AppColors.iconGrey, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.close, color: AppColors.iconGrey, size: 18),
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),

            // Category chips
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: _categories.map((cat) {
                  final sel = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.blue : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppColors.blue : AppColors.divider),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                              color: sel ? AppColors.white : AppColors.textSecondary,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Product grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMsg != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off, size: 48, color: AppColors.iconGrey),
                              const SizedBox(height: 12),
                              Text(_errorMsg!, style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _loadProduk, child: const Text('Coba Lagi')),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off, size: 48, color: AppColors.iconGrey),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Produk "$_searchQuery" tidak ditemukan'
                                        : 'Belum ada produk di kategori ini',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadProduk,
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.78,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) => ProductCard(product: _filtered[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BAGIAN 3: ProductCard (Yang sudah diperbaiki) ---
class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({Key? key, required this.product}) : super(key: key);

  String _formatRp(int val) => 'Rp ${val.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final inCart = cart.isInCart(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8E0D5),
                    child: const Icon(Icons.set_meal, color: AppColors.iconGrey, size: 48),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${_formatRp(product.price)}/kg',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('Produsen: ${product.producerName}',
                      style: const TextStyle(fontSize: 10, color: AppColors.blue),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stok: ${product.stock}kg',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${product.name} ditambahkan'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.blue,
                          ));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: inCart ? AppColors.successGreen : AppColors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(inCart ? Icons.check : Icons.add,
                              color: AppColors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}