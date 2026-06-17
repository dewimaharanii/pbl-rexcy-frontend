import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/admin_provider.dart';
import 'models/product_model.dart';
import 'providers/produksi_provider.dart';
import 'providers/transaksi_provider.dart';

// Screens - General
import 'screens/splash.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/history_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/dashboard_mitra.dart';
import 'screens/add_product_screen.dart';
import 'screens/role_switch.dart';

// Screens - Admin
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_data_mitra_screen.dart';
import 'screens/admin/admin_data_produksi_screen.dart';
import 'screens/admin/admin_data_produsen_screen.dart';
import 'screens/admin/admin_data_transaksi_screen.dart';
import 'screens/admin/admin_kelola_akun_screen.dart';
import 'screens/admin/admin_laporan_screen.dart';
import 'screens/admin/admin_pembayaran_screen.dart';

// Screens - Produsen
import 'screens/produsen/produsen_shell.dart'; // ✅ import shell
import 'screens/produsen/input_produksi_screen.dart';

void main() {
  runApp(const ExcyApp());
}

class ExcyApp extends StatelessWidget {
  const ExcyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProduksiProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
      ],
      child: MaterialApp(
        title: 'Rexcy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
        routes: {
          // General
          '/login':            (context) => const LoginScreen(),
          '/register':         (context) => const RegisterScreen(),
          '/home':             (context) => HomeScreen(),
          '/profile':          (context) => const ProfileScreen(),
          '/cart':             (context) => const CartScreen(),
          '/orders':           (context) => const OrdersScreen(),
          '/payment':          (context) => const PaymentScreen(),
          '/requests':         (context) => RequestsScreen(),
          '/history':          (context) => const HistoryScreen(),
          '/forgot-password':  (context) => const ForgotPasswordScreen(),
          '/dashboard-mitra':  (context) => const DashboardMitra(),
          '/add-product':      (context) => AddProductScreen(),
          '/role-switch':      (context) => RoleSwitch(),

          // Admin
          '/admin/dashboard':       (context) => AdminDashboardScreen(),
          '/admin/data-mitra':      (context) => AdminDataMitraScreen(),
          '/admin/data-produksi':   (context) => AdminDataProduksiScreen(),
          '/admin/data-produsen':   (context) => AdminDataProdusenScreen(),
          '/admin/data-transaksi':  (context) => AdminDataTransaksiScreen(),
          '/admin/kelola-akun':     (context) => AdminKelolaAkunScreen(),
          '/admin/laporan':         (context) => AdminLaporanScreen(),
          '/admin/pembayaran':      (context) => AdminPembayaranScreen(),

          // Produsen — semua lewat ProdusenShell
          '/produsen/dashboard':         (context) => const ProdusenShell(initialIndex: 0),
          '/produsen/daftar-produksi':   (context) => const ProdusenShell(initialIndex: 1),
          '/produsen/stok-saya':         (context) => const ProdusenShell(initialIndex: 2),
          '/produsen/permintaan-masuk':  (context) => const ProdusenShell(initialIndex: 3),
          '/produsen/riwayat-transaksi': (context) => const ProdusenShell(initialIndex: 4),
          '/produsen/profil':            (context) => const ProdusenShell(initialIndex: 5),
          '/produsen/input-produksi':    (context) => const InputProduksiScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final product = settings.arguments;
            return MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(product: product as ProductModel),
            );
          }
          return null;
        },
      ),
    );
  }
}