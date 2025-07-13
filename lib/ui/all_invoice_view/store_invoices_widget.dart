import 'package:agri_store/data/model/main_inventory_model/main_inventory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/my_database.dart';
import 'inventory_invoices_view_widget.dart';

class StoreInvoicesWidget extends StatelessWidget {
  DateTime? startDate;
  DateTime? endDate;
  bool isFiltered;
  String uId;
  StoreInvoicesWidget({required this.startDate, required this.endDate,required this.isFiltered,required this.uId});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<MainInventoryInvoiceModel>>(
            stream:
            isFiltered
                ? MyDataBase.getBuyInvoicesRealTimeUpdateByTime(
              uId!,
              startDate ?? DateTime.now(),
              endDate ?? DateTime.now(),
            )
                : MyDataBase.getBuyInvoicesRealTimeUpdate(uId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final invoiceList =
              snapshot.data?.docs.map((doc) => doc.data()).toList();

              if (invoiceList == null || invoiceList.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد فواتير حالياً",
                    style: GoogleFonts.abel(fontSize: 26, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: invoiceList.length,
                itemBuilder: (context, index) {
                  final invoice = invoiceList[index];
                  return InventoryInvoicesWidget(inventoryInvoiceModel: invoice);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
