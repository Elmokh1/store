import 'package:agri_store/data/model/client_invoice_model/sale_invoice_model.dart';
import 'package:agri_store/data/model/client_invoice_model/debt_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../MyDateUtils.dart';
import '../../data/model/product_model.dart';
import '../../data/my_database.dart';
import '../../logic/sale_invoice/sale_invoice_cubit.dart';
import '../../logic/sale_invoice/sale_invoice_state.dart';

class SaleInvoicePage extends StatefulWidget {
  static const routeName = 'sale_invoice';
  String? uId;

  SaleInvoicePage({super.key, this.uId});

  @override
  State<SaleInvoicePage> createState() => _SaleInvoicePageState();
}

class _SaleInvoicePageState extends State<SaleInvoicePage> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientIdController = TextEditingController();
  double clientOldDebtController = 0;
  final TextEditingController invoiceNumController = TextEditingController();

  DebtModel? selectedClient;
  String? selectedClientId;
  DateTime selectedDate = DateTime.now(); // Initialize selectedDate

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    clientNameController.dispose();
    clientIdController.dispose();
    invoiceNumController.dispose();
    super.dispose();
  }

  // Function to reset all relevant fields
  void _resetPage() {
    setState(() {
      context.read<SaleInvoiceCubit>().resetInvoice();
      clientNameController.clear();
      clientIdController.clear();
      clientOldDebtController = 0;
      invoiceNumController.clear();
      selectedClient = null;
      selectedClientId = null;
      selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleInvoiceState =
        context.watch<SaleInvoiceCubit>().state as SaleInvoiceLoaded;
    final items = saleInvoiceState.items;
    final total = saleInvoiceState.total;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فاتورة بيع',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'حفظ الفاتورة',
            onPressed: saveInvoice,
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
                          controller: invoiceNumController,
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
                            widget.uId ?? "",
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('حدث خطأ أثناء تحميل العملاء');
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
                              value: selectedClientId,
                              decoration: const InputDecoration(
                                labelText: 'اسم العميل',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items:
                                  clientList.map((client) {
                                    return DropdownMenuItem<String>(
                                      value: client.id,
                                      child: Text(client.clientName ?? ""),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedClientId = value;
                                  selectedClient = clientList.firstWhere(
                                    (c) => c.id == value,
                                  );
                                  clientNameController.text =
                                      selectedClient!.clientName ?? "";
                                  clientIdController.text =
                                      selectedClient!.id ?? "";
                                  clientOldDebtController =
                                      double.tryParse(
                                        "${selectedClient!.oldDebt ?? ""}",
                                      ) ??
                                      0.0;
                                });
                              },
                              // Handle initial selection if needed
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'تاريخ الفاتورة:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            InkWell(
                              onTap: showTaskDatePicker,
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
                                  MyDateUtils.formatTaskDate(selectedDate),
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
                  onPressed: addProduct,
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
                if (items.isNotEmpty)
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
                          DataColumn(label: Text('حذف')), // Add Delete Column
                        ],
                        rows:
                            items
                                .map(
                                  (item) => DataRow(
                                    cells: [
                                      DataCell(Text(item.productName ?? '')),
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
                                          onPressed: () => _removeItem(item),
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
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'لا توجد منتجات مضافة بعد',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(thickness: 1.5),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الإجمالي الكلي: ${total.toStringAsFixed(2)} ج',
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
  }

  void addProduct() {
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
                            widget.uId ?? "",
                          ).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('حدث خطأ أثناء تحميل المنتجات');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final productList =
                            snapshot.data?.docs.map((doc) {
                              final data = doc.data();
                              data.id = doc.id;
                              return data;
                            }).toList() ??
                            [];

                        if (productList.isEmpty) {
                          return const Text('لا توجد منتجات في المخزون');
                        }

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
                onPressed: () async {
                  if (selectedProduct != null) {
                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    final totalItem = quantity * price;

                    if (quantity <= 0) {
                      _showSnackBar(
                        'الكمية يجب أن تكون أكبر من صفر',
                        Colors.red,
                      );
                      return;
                    }
                    if (price <= 0) {
                      _showSnackBar(
                        'السعر يجب أن يكون أكبر من صفر',
                        Colors.red,
                      );
                      return;
                    }

                    // أضف للفاتورة عبر Cubit
                    context.read<SaleInvoiceCubit>().addProduct(
                      ProductModel(
                        id: selectedProductId,
                        productName: selectedProduct!.productName,
                        qun: quantity,
                        price: price,
                        total: totalItem,
                      ),
                    );

                    // نقص من المخزن
                    selectedProduct!.qun = quantity;
                    await MyDataBase.subtractProductFromInventory(
                      widget.uId ?? "",
                      selectedProduct!,
                    );

                    Navigator.pop(context);
                  } else {
                    _showSnackBar(
                      'الرجاء اختيار منتج وتحديد الكمية والسعر',
                      Colors.orange,
                    );
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

  void _removeItem(ProductModel itemToRemove) async {
    context.read<SaleInvoiceCubit>().removeProduct(itemToRemove);
  }

  void showTaskDatePicker() async {
    var date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700], // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;
    setState(() {
      selectedDate = date;
    });
  }

  void saveInvoice() async {
    final state = context.read<SaleInvoiceCubit>().state;
    final loadedState = state as SaleInvoiceLoaded;

    if (clientNameController.text.isEmpty || selectedClientId == null) {
      _showSnackBar('الرجاء اختيار العميل أولاً', Colors.orange);
      return;
    }
    if (invoiceNumController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال رقم الفاتورة', Colors.orange);
      return;
    }
    if (loadedState.items.isEmpty) {
      _showSnackBar('الرجاء إضافة منتجات إلى الفاتورة', Colors.orange);
      return;
    }

    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text(
              'جاري حفظ الفاتورة...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(minutes: 1),
      ),
    );

    try {
      String uId = widget.uId ?? "";
      double newDebt = clientOldDebtController + loadedState.total;

      SaleInvoiceModel saleInvoiceModel = SaleInvoiceModel(
        dateTime: selectedDate,
        cartItems: loadedState.items,
        totalOfInvoice: loadedState.total,
        clientId: clientIdController.text,
        clientName: clientNameController.text,
        createdAt: DateTime.now(),
        invoiceNum: invoiceNumController.text,
        newDebt: newDebt,
        oldDebt: clientOldDebtController,
      );

      await MyDataBase.addSaleInvoice(uId, saleInvoiceModel);
      await MyDataBase.editDebt(uId, clientIdController.text, newDebt);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar('تم حفظ الفاتورة بنجاح!', Colors.green);
      _resetPage();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar('حدث خطأ أثناء حفظ الفاتورة: ${e.toString()}', Colors.red);
      print('Error saving invoice: $e');
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        // Make it float
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
