import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetAllSalesUseCase {
  final SalesRepository repository;
  GetAllSalesUseCase(this.repository);
  Future<Either<Failure, List<Sale>>> call() => repository.getAllSales();
}

class SaveSaleUseCase {
  final SalesRepository repository;
  SaveSaleUseCase(this.repository);
  Future<Either<Failure, void>> call(Sale sale) => repository.saveSale(sale);
}

class DeleteSaleUseCase {
  final SalesRepository repository;
  DeleteSaleUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deleteSale(id);
}
