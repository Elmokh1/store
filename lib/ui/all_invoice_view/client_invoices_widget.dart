import 'package:agri_store/data/model/client_invoice_model/sale_invoice_model.dart';
import 'package:agri_store/data/my_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'client_invoice_view_widget.dart';

class ClientInvoicesWidget extends StatelessWidget {
  DateTime? startDate;
  DateTime? endDate;
  bool isFiltered;
  String? uId;

  ClientInvoicesWidget({
    required this.startDate,
    required this.endDate,
    required this.isFiltered,
    required this.uId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<SaleInvoiceModel>>(
            stream:
                isFiltered
                    ? MyDataBase.getSaleInvoiceRealTimeUpdateByDateTime(
                      uId!,
                      startDate ?? DateTime.now(),
                      endDate ?? DateTime.now(),
                    )
                    : MyDataBase.getSaleInvoiceRealTimeUpdate(uId!),
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
                  return ClientInvoiceViewWidget(saleInvoiceModel: invoice);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
