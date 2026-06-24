import 'package:get_it/get_it.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_usecases.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';
import '../../features/settings/data/repositories/printer_repository_impl.dart';
import '../../features/settings/domain/repositories/printer_repository.dart';
import '../../features/settings/presentation/bloc/printer_bloc.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/usecases/sales_usecases.dart';
import '../../features/sales/presentation/bloc/sales_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Product
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PrinterBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => SalesBloc(
      getAllSalesUseCase: sl(),
      saveSaleUseCase: sl(),
      deleteSaleUseCase: sl(),
    ),
  );

  // Use cases - Product
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));

  // Repository - Product
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );

  // Use cases - Shop
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Repository - Shop
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(),
  );

  // Settings / Printer
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(),
  );

  // Use cases - Sales
  sl.registerLazySingleton(() => GetAllSalesUseCase(sl()));
  sl.registerLazySingleton(() => SaveSaleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSaleUseCase(sl()));

  // Repository - Sales
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(),
  );
}
