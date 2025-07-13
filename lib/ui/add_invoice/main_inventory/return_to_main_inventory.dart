// add_to_inventory_page.dart

import 'package:agri_store/data/model/main_inventory_model/main_inventory_model.dart';
import 'package:agri_store/data/model/main_inventory_model/main_inventory_model.dart';
import 'package:agri_store/data/model/product_model.dart';
import 'package:agri_store/data/my_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReturnToMainInvoicePage extends StatefulWidget {
  String? uId;

  ReturnToMainInvoicePage({this.uId});

  @override
  State<ReturnToMainInvoicePage> createState() =>
      _ReturnToMainInvoicePageState();
}

class _ReturnToMainInvoicePageState extends State<ReturnToMainInvoicePage> {
  final List<ProductModel> items = [];
  final TextEditingController invoiceNumController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void addProduct() {
    ProductModel? selectedProduct;
    int quantity = 1;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'إضافة منتج',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot<ProductModel>>(
                  stream: MyDataBase.getProductRealTimeUpdate(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('حدث خطأ أثناء تحميل المنتجات');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    final productList =
                        snapshot.data?.docs.map((doc) {
                          final data = doc.data();
                          data.id = doc.id; // ربط الـ id من Firestore
                          return data;
                        }).toList() ??
                        [];

                    if (productList.isEmpty) {
                      return Text('لا توجد منتجات');
                    }

                    return DropdownButtonFormField<ProductModel>(
                      decoration: InputDecoration(
                        labelText: 'اسم المنتج',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items:
                          productList.map((product) {
                            return DropdownMenuItem<ProductModel>(
                              value: product,
                              child: Text(product.productName ?? ""),
                            );
                          }).toList(),
                      onChanged: (value) {
                        selectedProduct = value;
                      },
                    );
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedProduct != null) {
                    selectedProduct!.qun = quantity;

                    await MyDataBase.subtractProductFromInventory(
                      widget.uId ?? "",
                      selectedProduct!,
                    );

                    setState(() {
                      items.add(
                        ProductModel(
                          id: selectedProduct!.id,
                          productName: selectedProduct!.productName,
                          qun: quantity,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('موافق'),
              ),
            ],
          ),
    );
  }

  void addReturnInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    MainInventoryInvoiceModel returnToMain = MainInventoryInvoiceModel(
      invoiceNum: invoiceNumController.text,
      cartItems: items,
      itemIds: items.map((e) => e.id ?? '').toList(),
      // ✅ أضف هذا السطر
      dateTime: DateTime.now(),
      isReturn: false,
    );

    await MyDataBase.addReturnToMain(widget.uId ?? "", returnToMain);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم حفظ الفاتورة بنجاح')));

    invoiceNumController.clear();
    setState(() {
      items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('فاتورة الإضافة إلى المخزن'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: invoiceNumController,
                      decoration: InputDecoration(
                        labelText: 'رقم الفاتورة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال رقم الفاتورة';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('إضافة منتج'),
                  onPressed: addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 40,
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey[200],
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'اسم المنتج',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'العدد',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows:
                              items
                                  .map(
                                    (item) => DataRow(
                                      cells: [
                                        DataCell(Text(item.productName ?? '')),
                                        DataCell(
                                          Text(item.qun?.toString() ?? '0'),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('حفظ الفاتورة'),
                  onPressed: addReturnInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
}
