import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';   // ← import HomeContent dari sini
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardMitra extends StatefulWidget {
  const DashboardMitra({Key? key}) : super(key: key);
  @override
  State<DashboardMitra> createState() => _DashboardMitraState();
}

class _DashboardMitraState extends State<DashboardMitra> {
  int _navIndex = 0;

  // Hapus 'const' di depan array [ agar HomeScreen bisa dieksekusi
  final List<Widget> _screens = [
    HomeScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}