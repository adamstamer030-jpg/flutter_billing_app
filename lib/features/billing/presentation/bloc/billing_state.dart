part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final bool saleConfirmed;
  final double discountValue;
  final bool discountIsPercentage;
  final String paymentMethod;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.saleConfirmed = false,
    this.discountValue = 0,
    this.discountIsPercentage = false,
    this.paymentMethod = 'نقداً',
  });

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  double get discountAmount {
    if (discountIsPercentage) {
      return totalAmount * (discountValue / 100);
    }
    return discountValue;
  }

  double get netAmount => totalAmount - discountAmount;

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? saleConfirmed,
    double? discountValue,
    bool? discountIsPercentage,
    String? paymentMethod,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      saleConfirmed: saleConfirmed ?? this.saleConfirmed,
      discountValue: discountValue ?? this.discountValue,
      discountIsPercentage: discountIsPercentage ?? this.discountIsPercentage,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        isPrinting,
        printSuccess,
        saleConfirmed,
        discountValue,
        discountIsPercentage,
        paymentMethod,
      ];
}
