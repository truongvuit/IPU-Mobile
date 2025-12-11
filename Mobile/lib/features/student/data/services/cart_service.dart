import '../../presentation/bloc/student_state.dart';


class CartService {
  CartService._internal();
  static final CartService _instance = CartService._internal();
  static CartService get instance => _instance;

  final List<CartItem> _cartItems = [];

  List<CartItem> get items => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.length;
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }

  bool isInCart(int classId) {
    return _cartItems.any((item) => item.classId == classId);
  }

  void addItem(CartItem item) {
    if (!isInCart(item.classId)) {
      _cartItems.add(item);
    }
  }

  void removeItem(int classId) {
    _cartItems.removeWhere((item) => item.classId == classId);
  }

  void clear() {
    _cartItems.clear();
  }

  List<int> get classIds => _cartItems.map((item) => item.classId).toList();
}
