import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../sales/data/models/sale_model.dart';
import '../../../product/data/models/product_model.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  BillingBloc({required this.getProductByBarcodeUseCase})
      : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<SetPaymentMethodEvent>(_onSetPaymentMethod);
    on<ConfirmSaleEvent>(_onConfirmSale);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) =>
          emit(state.copyWith(error: 'المنتج غير موجود: ${event.barcode}')),
      (product) => add(AddProductToCartEvent(product)),
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final cleanState = state.copyWith(error: null);
    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      final items = List<CartItem>.from(cleanState.cartItems);
      items[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(cleanState.copyWith(cartItems: items, error: null));
    } else {
      final newItem = CartItem(product: event.product);
      emit(cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem], error: null));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }
    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(
      discountValue: event.discount,
      discountIsPercentage: event.isPercentage,
    ));
  }

  void _onSetPaymentMethod(
      SetPaymentMethodEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  Future<void> _onConfirmSale(
      ConfirmSaleEvent event, Emitter<BillingState> emit) async {
    try {
      final saleItems = state.cartItems
          .map((item) => SaleItemModel(
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                unitPrice: item.product.price,
              ))
          .toList();

      final sale = SaleModel(
        id: const Uuid().v4(),
        date: DateTime.now(),
        items: saleItems,
        total: state.totalAmount,
        discount: state.discountAmount,
        paymentMethod: state.paymentMethod,
      );

      // Save sale
      await HiveDatabase.salesBox.put(sale.id, sale);

      // Deduct stock from products
      final productBox = HiveDatabase.productBox;
      for (final item in state.cartItems) {
        final existing = productBox.get(item.product.id);
        if (existing != null && existing.stock > 0) {
          final newStock = (existing.stock - item.quantity).clamp(0, 999999);
          final updated = ProductModel(
            id: existing.id,
            name: existing.name,
            barcode: existing.barcode,
            price: existing.price,
            stock: newStock,
          );
          await productBox.put(existing.id, updated);
        }
      }

      emit(state.copyWith(saleConfirmed: true));
    } catch (e) {
      emit(state.copyWith(error: 'فشل حفظ الفاتورة: $e'));
    }
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(error: 'فشل الاتصال بالطابعة!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(error: 'الطابعة غير متصلة!', clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.product.price,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
        shopName: event.shopName,
        address1: event.address1,
        address2: event.address2,
        phone: event.phone,
        items: items,
        total: state.netAmount,
        footer: event.footer,
        discount: state.discountAmount,
        paymentMethod: state.paymentMethod,
      );

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'فشل الطباعة: $e', clearError: false));
      emit(state.copyWith(clearError: true));
    }
  }
}
