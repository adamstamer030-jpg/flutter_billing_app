part of 'sales_bloc.dart';

enum SalesStatus { initial, loading, loaded, saved, error }

class SalesState extends Equatable {
  final SalesStatus status;
  final List<Sale> sales;
  final String? message;

  const SalesState({
    this.status = SalesStatus.initial,
    this.sales = const [],
    this.message,
  });

  // Summary helpers
  double get todayTotal {
    final now = DateTime.now();
    return sales
        .where((s) =>
            s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day)
        .fold(0, (sum, s) => sum + s.netTotal);
  }

  double get monthTotal {
    final now = DateTime.now();
    return sales
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold(0, (sum, s) => sum + s.netTotal);
  }

  int get todayCount {
    final now = DateTime.now();
    return sales
        .where((s) =>
            s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day)
        .length;
  }

  Map<String, double> get topProducts {
    final Map<String, double> totals = {};
    for (final sale in sales) {
      for (final item in sale.items) {
        totals[item.productName] =
            (totals[item.productName] ?? 0) + item.quantity;
      }
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  SalesState copyWith({
    SalesStatus? status,
    List<Sale>? sales,
    String? message,
  }) {
    return SalesState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, sales, message];
}
