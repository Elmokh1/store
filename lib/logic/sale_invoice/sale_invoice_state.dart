import 'package:equatable/equatable.dart';
import '../../data/model/client_invoice_model/debt_model.dart';
import '../../data/model/product_model.dart';

abstract class SaleInvoiceState extends Equatable {
  const SaleInvoiceState();

  @override
  List<Object?> get props => [];
}

class SaleInvoiceInitial extends SaleInvoiceState {}

class SaleInvoiceLoading extends SaleInvoiceState {}

class SaleInvoiceLoaded extends SaleInvoiceState {
  final List<ProductModel> items;
  final double total;
  final DebtModel? selectedClient;
  final DateTime selectedDate;
  final String invoiceNum;
  final String clientName;
  final String clientId;
  final double oldDebt;

  const SaleInvoiceLoaded({
    required this.items,
    required this.total,
    required this.selectedClient,
    required this.selectedDate,
    required this.invoiceNum,
    required this.clientName,
    required this.clientId,
    required this.oldDebt,
  });

  @override
  List<Object?> get props => [
    items,
    total,
    selectedClient,
    selectedDate,
    invoiceNum,
    clientName,
    clientId,
    oldDebt,
  ];

  SaleInvoiceLoaded copyWith({
    List<ProductModel>? items,
    double? total,
    DebtModel? selectedClient,
    DateTime? selectedDate,
    String? invoiceNum,
    String? clientName,
    String? clientId,
    double? oldDebt,
  }) {
    return SaleInvoiceLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
      selectedClient: selectedClient ?? this.selectedClient,
      selectedDate: selectedDate ?? this.selectedDate,
      invoiceNum: invoiceNum ?? this.invoiceNum,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      oldDebt: oldDebt ?? this.oldDebt,
    );
  }
}

class SaleInvoiceFailure extends SaleInvoiceState {
  final String error;

  const SaleInvoiceFailure(this.error);

  @override
  List<Object?> get props => [error];
}
