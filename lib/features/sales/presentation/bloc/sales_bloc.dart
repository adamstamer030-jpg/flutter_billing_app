import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/sales_usecases.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetAllSalesUseCase getAllSalesUseCase;
  final SaveSaleUseCase saveSaleUseCase;
  final DeleteSaleUseCase deleteSaleUseCase;

  SalesBloc({
    required this.getAllSalesUseCase,
    required this.saveSaleUseCase,
    required this.deleteSaleUseCase,
  }) : super(const SalesState()) {
    on<LoadSalesEvent>(_onLoad);
    on<SaveSaleEvent>(_onSave);
    on<DeleteSaleEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadSalesEvent event, Emitter<SalesState> emit) async {
    emit(state.copyWith(status: SalesStatus.loading));
    final result = await getAllSalesUseCase();
    result.fold(
      (f) => emit(state.copyWith(status: SalesStatus.error, message: f.message)),
      (sales) => emit(state.copyWith(status: SalesStatus.loaded, sales: sales)),
    );
  }

  Future<void> _onSave(SaveSaleEvent event, Emitter<SalesState> emit) async {
    final result = await saveSaleUseCase(event.sale);
    result.fold(
      (f) => emit(state.copyWith(status: SalesStatus.error, message: f.message)),
      (_) {
        emit(state.copyWith(status: SalesStatus.saved));
        add(LoadSalesEvent());
      },
    );
  }

  Future<void> _onDelete(DeleteSaleEvent event, Emitter<SalesState> emit) async {
    final result = await deleteSaleUseCase(event.id);
    result.fold(
      (f) => emit(state.copyWith(status: SalesStatus.error, message: f.message)),
      (_) => add(LoadSalesEvent()),
    );
  }
}
