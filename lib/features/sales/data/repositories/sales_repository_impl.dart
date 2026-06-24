import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  @override
  Future<Either<Failure, List<Sale>>> getAllSales() async {
    try {
      final box = HiveDatabase.salesBox;
      final sales = box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(sales);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSale(Sale sale) async {
    try {
      final model = SaleModel.fromEntity(sale);
      await HiveDatabase.salesBox.put(sale.id, model);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSale(String id) async {
    try {
      await HiveDatabase.salesBox.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
