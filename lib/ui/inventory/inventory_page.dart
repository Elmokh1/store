import 'package:agri_store/data/model/product_model.dart';
import 'package:agri_store/data/my_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../add_invoice/main_inventory/all_invoice_include_item.dart';

class InventoryPage extends StatefulWidget {
  static const String routeName = "InventoryPage";
  String? uId;

  InventoryPage({this.uId});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('المخزن'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: StreamBuilder<QuerySnapshot<ProductModel>>(
        stream: MyDataBase.getProductToInventoryCollection(widget.uId??"").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في تحميل البيانات'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data?.docs ?? [];
          final filteredProducts = products.where((doc) {
            final product = doc.data();
            final name = product.productName ?? '';
            return name.toLowerCase().contains(searchText.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'ابحث باسم المنتج',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchText = '';
                        });
                      },
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(child: Text('لا توجد منتجات تطابق البحث'))
                      : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index].data();
                      final productId = product.id;

                      return InkWell(
                        onTap: () async {
                          final invoices = await MyDataBase
                              .getInvoicesByProductIdFirestore(
                            userId: widget.uId??"",
                            itemId: productId??"",
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllInvoiceIncludeItem(
                                    inventoryInvoiceModel: invoices,
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin:
                          const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  '${product.qun ?? 0}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 12),
                                  height: 30,
                                  width: 1,
                                  color: Colors.grey[400],
                                ),
                                Expanded(
                                  child: Text(
                                    product.productName ?? '',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
