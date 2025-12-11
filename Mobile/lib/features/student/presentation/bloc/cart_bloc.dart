import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/cart_service.dart';
import 'student_state.dart'; 


abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItem item;
  const AddToCart(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final int classId;
  const RemoveFromCart(this.classId);
  @override
  List<Object?> get props => [classId];
}

class ClearCart extends CartEvent {}


class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get itemCount => items.length;
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.price);
  List<int> get classIds => items.map((e) => e.classId).toList();
  bool containsClass(int classId) =>
      items.any((item) => item.classId == classId);

  @override
  List<Object?> get props => [items];
}


class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService = CartService.instance;

  CartBloc() : super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);

    
    add(LoadCart());
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    emit(CartState(items: _cartService.items));
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    if (_cartService.isInCart(event.item.classId)) return;
    _cartService.addItem(event.item);
    emit(CartState(items: _cartService.items));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    _cartService.removeItem(event.classId);
    emit(CartState(items: _cartService.items));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    _cartService.clear();
    emit(const CartState(items: []));
  }
}
