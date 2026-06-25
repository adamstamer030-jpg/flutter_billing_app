import 'package:hive/hive.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class SaleModel extends Sale {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final DateTime date;

  @override
  @HiveField(2)
  final List<SaleItemModel> items;

  @override
  @HiveField(3)
  final double total;

  @override
  @HiveField(4)
  final double discount;

  @override
  @HiveField(5)
  final String paymentMethod;

  const SaleModel({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.discount,
    required this.paymentMethod,
  }) : super(
          id: id,
          date: date,
          items: items,
          total: total,
          discount: discount,
          paymentMethod: paymentMethod,
        );

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      date: sale.date,
      items: sale.items
          .map((i) => SaleItemModel(
                productId: i.productId,
                productName: i.productName,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
              ))
          .toList(),
      total: sale.total,
      discount: sale.discount,
      paymentMethod: sale.paymentMethod,
    );
  }
}

@HiveType(typeId: 3)
class SaleItemModel extends SaleItem {
  @override
  @HiveField(0)
  final String productId;

  @override
  @HiveField(1)
  final String productName;

  @override
  @HiveField(2)
  final int quantity;

  @override
  @HiveField(3)
  final double unitPrice;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  }) : super(
          productId: productId,
          productName: productName,
          quantity: quantity,
          unitPrice: unitPrice,
        );
}
