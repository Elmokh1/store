import 'package:agri_store/data/model/client_invoice_model/sale_invoice_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/model/client_invoice_model/debt_model.dart';
import '../../../../../data/model/client_invoice_model/invoice_model.dart';
import '../../../../../data/my_database.dart';
import 'client_details_widget.dart';

class ClientDebtDetails extends StatefulWidget {
  DebtModel debtModel;
  String uId;

  ClientDebtDetails({required this.debtModel, required this.uId});

  @override
  State<ClientDebtDetails> createState() => _ClientDebtDetailsState();
}

class _ClientDebtDetailsState extends State<ClientDebtDetails> {
  late Stream<QuerySnapshot<ClientInvoiceModel>> searchStream;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: []),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Divider(),
          const IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Center(
                      child: Text("التاريخ ", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: Center(child: VerticalDivider())),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text("تحصيل / بيع", style: TextStyle(fontSize: 12)),
                  ),
                ),
                Expanded(flex: 1, child: Center(child: VerticalDivider())),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text("الرصيد", style: TextStyle(fontSize: 12)),
                  ),
                ),
                Expanded(flex: 1, child: Center(child: VerticalDivider())),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text("رقم الفاتوره", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<SaleInvoiceModel>>(
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text(snapshot.error.toString());

                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var saleInvoiceModelList =
                    snapshot.data?.docs.map((doc) => doc.data()).toList();
                if (saleInvoiceModelList?.isEmpty == true) {
                  return Center(
                    child: Text(
                      "لا توجد فواتير ",
                      style: GoogleFonts.abel(fontSize: 30),
                    ),
                  );
                }
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final SaleInvoiceModel = saleInvoiceModelList![index];
                    print(saleInvoiceModelList[0].invoiceNum);
                    return ClientDebtDetailsWidget(
                      saleInvoiceModel: SaleInvoiceModel,
                    );
                  },
                  itemCount: saleInvoiceModelList?.length ?? 0,
                );
              },
              stream: MyDataBase.getSaleInvoiceForClientRealTimeUpdate(
                widget.uId ?? "",
                widget.debtModel.id,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
