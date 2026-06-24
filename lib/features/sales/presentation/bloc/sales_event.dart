part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
  @override
  List<Object?> get props => [];
}

class LoadSalesEvent extends SalesEvent {}

class SaveSaleEvent extends SalesEvent {
  final Sale sale;
  const SaveSaleEvent(this.sale);
  @override
  List<Object?> get props => [sale];
}

class DeleteSaleEvent extends SalesEvent {
  final String id;
  const DeleteSaleEvent(this.id);
  @override
  List<Object?> get props => [id];
}
