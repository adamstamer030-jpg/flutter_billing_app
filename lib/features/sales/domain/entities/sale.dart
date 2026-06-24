import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice];
}

class Sale extends Equatable {
  final String id;
  final DateTime date;
  final List<SaleItem> items;
  final double total;
  final double discount;
  final String paymentMethod;

  const Sale({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.discount,
    required this.paymentMethod,
  });

  double get netTotal => total - discount;

  @override
  List<Object?> get props => [id, date, items, total, discount, paymentMethod];
}
