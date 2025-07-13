import 'package:agri_store/data/model/client_invoice_model/debt_model.dart';
import 'package:agri_store/data/model/client_invoice_model/sale_invoice_model.dart';
import 'package:agri_store/data/model/product_model.dart';
import 'package:agri_store/data/my_database.dart';
import 'package:agri_store/logic/return_invoice/return_invoice_cubit.dart';
import 'package:agri_store/logic/return_invoice/return_invoice_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../MyDateUtils.dart';

class ReturnInvoicePage extends StatelessWidget {
  final String? uId;

  const ReturnInvoicePage({super.key, this.uId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReturnInvoiceCubit(),
      child: BlocBuilder<ReturnInvoiceCubit, ReturnInvoiceState>(
        builder: (context, state) {
          if (state is! ReturnInvoiceLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<ReturnInvoiceCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'فاتورة مرتجع',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green[700],
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'حفظ الفاتورة',
                  onPressed: () => _saveInvoice(context, state),
                ),
              ],
            ),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: TextEditingController(
                                  text: state.invoiceNum,
                                ),
                                onChanged: cubit.updateInvoiceNum,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الفاتورة',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.confirmation_number),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              StreamBuilder<QuerySnapshot<DebtModel>>(
                                stream: MyDataBase.getDebtRealTimeUpdate(
                                  uId ?? "",
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                      'حدث خطأ أثناء تحميل العملاء',
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final clientList =
                                      snapshot.data?.docs.map((doc) {
                                        final data = doc.data();
                                        data.id = doc.id;
                                        return data;
                                      }).toList() ??
                                      [];

                                  return DropdownButtonFormField<String>(
                                    value: state.selectedClient?.id,
                                    decoration: const InputDecoration(
                                      labelText: 'اسم العميل',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    items:
                                        clientList.map((client) {
                                          return DropdownMenuItem<String>(
                                            value: client.id,
                                            child: Text(
                                              client.clientName ?? "",
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      final selected = clientList.firstWhere(
                                        (c) => c.id == value,
                                      );
                                      cubit.selectClient(selected);
                                      cubit.updateClientName(
                                        selected.clientName ?? "",
                                      );
                                      cubit.updateClientId(selected.id ?? "");
                                      cubit.updateOldDebt(
                                        selected.oldDebt ?? 0,
                                      );
                                    },
                                    hint: Text(
                                      clientList.isNotEmpty
                                          ? 'اختر عميل'
                                          : 'لا يوجد عملاء',
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'تاريخ الفاتورة:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap:
                                        () =>
                                            _showTaskDatePicker(context, state),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        MyDateUtils.formatTaskDate(
                                          state.selectedDate,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductDialog(context, state),
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'إضافة منتج',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.items.isNotEmpty)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey[300],
                              ),
                              columnSpacing: 30,
                              columns: const [
                                DataColumn(label: Text('اسم المنتج')),
                                DataColumn(label: Text('العدد')),
                                DataColumn(label: Text('السعر')),
                                DataColumn(label: Text('الإجمالي')),
                                DataColumn(label: Text('حذف')),
                              ],
                              rows:
                                  state.items
                                      .map(
                                        (item) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(item.productName ?? ''),
                                            ),
                                            DataCell(Text('${item.qun ?? 0}')),
                                            DataCell(
                                              Text(
                                                '${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${item.total?.toStringAsFixed(2) ?? '0.00'}',
                                              ),
                                            ),
                                            DataCell(
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed:
                                                    () => context
                                                        .read<
                                                          ReturnInvoiceCubit
                                                        >()
                                                        .removeProduct(item),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'لا توجد منتجات مضافة بعد',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1.5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الإجمالي الكلي: ${state.total.toStringAsFixed(2)} ج',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, ReturnInvoiceLoaded state) {
    final loaded =
        context.read<ReturnInvoiceCubit>().state as ReturnInvoiceLoaded;

    String? selectedProductId;
    ProductModel? selectedProduct;
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'إضافة منتج',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<QuerySnapshot<ProductModel>>(
                      stream:
                          MyDataBase.getProductToInventoryCollection(
                            loaded.clientId,
                          ).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return const Text('حدث خطأ أثناء تحميل المنتجات');
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const CircularProgressIndicator();

                        final productList =
                            snapshot.data?.docs.map((doc) {
                              final data = doc.data();
                              data.id = doc.id;
                              return data;
                            }).toList() ??
                            [];

                        if (productList.isEmpty)
                          return const Text('لا توجد منتجات في المخزون');

                        return DropdownButtonFormField<String>(
                          value: selectedProductId,
                          decoration: InputDecoration(
                            labelText: 'اسم المنتج',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items:
                              productList.map((product) {
                                return DropdownMenuItem<String>(
                                  value: product.id,
                                  child: Text(product.productName ?? ""),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedProductId = value;
                              selectedProduct = productList.firstWhere(
                                (p) => p.id == value,
                              );
                              priceController.text =
                                  selectedProduct!.price?.toStringAsFixed(2) ??
                                  '';
                            });
                          },
                          hint: const Text('اختر منتج'),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'الكمية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedProduct != null) {
                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final totalItem = quantity * price;

                    if (quantity > 0 && price > 0) {
                      context.read<ReturnInvoiceCubit>().addProduct(
                        ProductModel(
                          id: selectedProductId,
                          productName: selectedProduct!.productName,
                          qun: quantity,
                          price: price,
                          total: totalItem,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('موافق'),
              ),
            ],
          ),
    );
  }

  void _showTaskDatePicker(
    BuildContext context,
    ReturnInvoiceLoaded state,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      context.read<ReturnInvoiceCubit>().updateDate(picked);
    }
  }

  void _saveInvoice(BuildContext context, ReturnInvoiceLoaded state) async {
    if (state.clientName.isEmpty || state.clientId.isEmpty) {
      _showSnackBar(context, 'الرجاء اختيار العميل أولاً', Colors.orange);
      return;
    }
    if (state.invoiceNum.isEmpty) {
      _showSnackBar(context, 'الرجاء إدخال رقم الفاتورة', Colors.orange);
      return;
    }
    if (state.items.isEmpty) {
      _showSnackBar(context, 'الرجاء إضافة منتجات إلى الفاتورة', Colors.orange);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            const Text(
              'جاري حفظ الفاتورة...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(minutes: 1),
      ),
    );

    try {
      final newDebt = state.oldDebt - state.total;
      final invoice = SaleInvoiceModel(
        isInvoice: true,
        dateTime: state.selectedDate,
        cartItems: state.items,
        clientId: state.clientId,
        clientName: state.clientName,
        createdAt: DateTime.now(),
        invoiceNum: state.invoiceNum,
        newDebt: newDebt,
        oldDebt: state.oldDebt,
        totalOfInvoice: state.total,
      );

      await MyDataBase.addSaleInvoice(uId ?? "", invoice);
      await MyDataBase.editDebt(uId ?? "", state.clientId, newDebt);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar(context, 'تم حفظ الفاتورة بنجاح!', Colors.green);
      context.read<ReturnInvoiceCubit>().resetInvoice();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar(context, 'حدث خطأ أثناء حفظ الفاتورة: $e', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
