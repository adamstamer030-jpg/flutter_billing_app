import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/sale.dart';

abstract class SalesRepository {
  Future<Either<Failure, List<Sale>>> getAllSales();
  Future<Either<Failure, void>> saveSale(Sale sale);
  Future<Either<Failure, void>> deleteSale(String id);
}
