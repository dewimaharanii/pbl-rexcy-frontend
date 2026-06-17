import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get totalItems => _items.fold(0, (sum, i) => sum + i.qty);
  int get totalPrice => _items.fold(0, (sum, i) => sum + i.subtotal);

  void addToCart(ProductModel product) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(CartItemModel(product: product));
    }
    notifyListeners();
  }
void clearCart() {
    _items.clear();
    notifyListeners();
  }
  
  void increment(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) { _items[idx].qty++; notifyListeners(); }
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (_items[idx].qty > 1) {
        _items[idx].qty--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) => _items.any((i) => i.product.id == productId);
  int getQty(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    return idx >= 0 ? _items[idx].qty : 0;
  }
}