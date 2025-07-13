import 'package:agri_store/data/model/main_inventory_model/main_inventory_model.dart';
import 'package:agri_store/data/model/product_model.dart';
import 'package:agri_store/data/my_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddToInventoryPage extends StatefulWidget {
  String? uId;

  AddToInventoryPage({this.uId});

  @override
  State<AddToInventoryPage> createState() => _AddToInventoryPageState();
}

class _AddToInventoryPageState extends State<AddToInventoryPage> {
  final List<ProductModel> items = [];
  final TextEditingController invoiceNumController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Helper function for showing SnackBars (added for consistency)
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

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
            // Consistent border radius
            title: const Text(
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
                      return const Text('حدث خطأ أثناء تحميل المنتجات');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final productList =
                        snapshot.data?.docs.map((doc) {
                          final data = doc.data();
                          data.id = doc.id; // ربط الـ id من Firestore
                          return data;
                        }).toList() ??
                        [];

                    if (productList.isEmpty) {
                      return const Text('لا توجد منتجات');
                    }

                    return DropdownButtonFormField<ProductModel>(
                      decoration: InputDecoration(
                        labelText: 'اسم المنتج',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Consistent border radius
                        ),
                        prefixIcon: const Icon(
                          Icons.category,
                        ), // Added icon for consistency
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
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Consistent border radius
                    ),
                    prefixIcon: const Icon(
                      Icons.numbers,
                    ), // Added icon for consistency
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
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedProduct != null && quantity > 0) {
                    // Added quantity check
                    selectedProduct!.qun = quantity;

                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'جاري إضافة المنتج...',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.blueAccent,
                        duration: const Duration(minutes: 1),
                      ),
                    );

                    try {
                      await MyDataBase.addProductToInventory(
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
                      ScaffoldMessenger.of(
                        context,
                      ).hideCurrentSnackBar(); // Hide loading
                      _showSnackBar('تم إضافة المنتج بنجاح!', Colors.green);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).hideCurrentSnackBar(); // Hide loading
                      _showSnackBar(
                        'حدث خطأ أثناء إضافة المنتج: ${e.toString()}',
                        Colors.red,
                      );
                      print('Error adding product to inventory: $e');
                    }
                  } else {
                    _showSnackBar(
                      'الرجاء اختيار منتج وإدخال كمية صحيحة',
                      Colors.orange,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], // Consistent button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // Consistent border radius
                ),
                child: const Text(
                  'موافق',
                  style: TextStyle(color: Colors.white),
                ), // Consistent text color
              ),
            ],
          ),
    );
  }

  void addBuyInvoice() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('الرجاء إدخال رقم الفاتورة أولاً', Colors.orange);
      return;
    }
    if (items.isEmpty) {
      _showSnackBar('الرجاء إضافة منتجات إلى الفاتورة', Colors.orange);
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text(
              'جاري حفظ فاتورة الإضافة...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(minutes: 1), // Indefinite duration
      ),
    );

    try {
      MainInventoryInvoiceModel buyInvoiceModel = MainInventoryInvoiceModel(
        invoiceNum: invoiceNumController.text,
        cartItems: items,
        itemIds: items.map((e) => e.id ?? '').toList(),
        // ✅ أضف هذا السطر
        dateTime: DateTime.now(),
        isReturn: false,
      );

      await MyDataBase.addBuyInvoice(widget.uId ?? "", buyInvoiceModel);

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
      _showSnackBar('تم حفظ الفاتورة بنجاح!', Colors.green);
      invoiceNumController.clear();
      setState(() {
        items.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
      _showSnackBar('حدث خطأ أثناء حفظ الفاتورة: ${e.toString()}', Colors.red);
      print('Error saving buy invoice: $e'); // Log the error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA), // Light background color
      appBar: AppBar(
        title: const Text(
          'فاتورة الإضافة إلى المخزن',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700], // Consistent app bar color
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Consistent icon color
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // Right-to-left direction for Arabic
        child: Padding(
          padding: const EdgeInsets.all(16), // Consistent padding
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // Stretch children horizontally
              children: [
                Card(
                  // Updated borderRadius and elevation for consistency
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: invoiceNumController,
                      decoration: InputDecoration(
                        labelText: 'رقم الفاتورة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Consistent border radius
                        ),
                        prefixIcon: const Icon(
                          Icons.confirmation_number,
                        ), // Added icon for consistency
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
                const SizedBox(height: 20), // Consistent spacing
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  // Consistent icon and color
                  label: const Text(
                    'إضافة منتج',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    // Consistent button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Consistent border radius
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    // Consistent padding
                    textStyle: const TextStyle(
                      fontSize: 16,
                    ), // Consistent text style
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Card(
                    // Updated borderRadius and elevation for consistency
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
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
                  icon: const Icon(Icons.save, color: Colors.white),
                  // Consistent icon and color
                  label: const Text(
                    'حفظ الفاتورة',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: addBuyInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    // Consistent button color
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    // Consistent padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Consistent border radius
                    textStyle: const TextStyle(
                      fontSize: 16,
                    ), // Consistent text style
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
