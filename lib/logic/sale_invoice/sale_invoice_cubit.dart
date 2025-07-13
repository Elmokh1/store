import 'package:agri_store/data/model/client_invoice_model/debt_model.dart';
import 'package:agri_store/data/model/product_model.dart';
import 'package:agri_store/logic/sale_invoice/sale_invoice_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleInvoiceCubit extends Cubit<SaleInvoiceState> {
  SaleInvoiceCubit()
    : super(
        SaleInvoiceLoaded(
          items: [],
          total: 0,
          selectedClient: null,
          selectedDate: DateTime.now(),
          invoiceNum: '',
          clientName: '',
          clientId: '',
          oldDebt: 0,
        ),
      );

  void addProduct(ProductModel product) {
    final currentState = state as SaleInvoiceLoaded;
    if (state is SaleInvoiceLoaded) {
      final updatedItems = [...currentState.items, product];
      final updatedTotal = currentState.total + (product.total ?? 0);
      emit(currentState.copyWith(items: updatedItems, total: updatedTotal));
    }
  }

  void removeProduct(ProductModel product) {
    final currentState = state as SaleInvoiceLoaded;
    if (state is SaleInvoiceLoaded) {
      final updatedItems = [...currentState.items]..remove(product);
      final updatedTotal = currentState.total - (product.total ?? 0);
      emit(currentState.copyWith(items: updatedItems, total: updatedTotal));
    }
  }

  void selectClient(DebtModel? client) {
    final currentState = state;
    if (currentState is SaleInvoiceLoaded) {
      emit(currentState.copyWith(selectedClient: client));
    }
  }

  void updateDate(DateTime newDate) {
    final currentState = state;
    if (currentState is SaleInvoiceLoaded) {
      emit(currentState.copyWith(selectedDate: newDate));
    }
  }

  void resetInvoice() {
    emit(
      SaleInvoiceLoaded(
        items: [],
        total: 0,
        selectedClient: null,
        selectedDate: DateTime.now(),
        invoiceNum: '',
        clientName: '',
        clientId: '',
        oldDebt: 0,
      ),
    );
  }

  void updateInvoiceNum(String invoiceNum) {
    final current = state as SaleInvoiceLoaded;
    emit(current.copyWith(invoiceNum: invoiceNum));
  }

  void updateClientName(String name) {
    final current = state as SaleInvoiceLoaded;
    emit(current.copyWith(clientName: name));
  }

  void updateClientId(String id) {
    final current = state as SaleInvoiceLoaded;
    emit(current.copyWith(clientId: id));
  }

  void updateOldDebt(double debt) {
    final current = state as SaleInvoiceLoaded;
    emit(current.copyWith(oldDebt: debt));
  }
}
