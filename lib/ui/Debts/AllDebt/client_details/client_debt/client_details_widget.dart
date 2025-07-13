import 'package:agri_store/ui/Debts/AllDebt/client_details/client_debt/invoice_details_for_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../data/model/client_invoice_model/invoice_model.dart';
import '../../../../../data/model/client_invoice_model/sale_invoice_model.dart';

class ClientDebtDetailsWidget extends StatelessWidget {
  SaleInvoiceModel saleInvoiceModel;
  ClientDebtDetailsWidget({required this.saleInvoiceModel});

  @override
  Widget build(BuildContext context) {
    // Define the color based on the conditions
    Color displayColor;
    if (saleInvoiceModel.isInvoice == true && saleInvoiceModel.cartItems == null) {
      displayColor = Colors.green; // Blue if isInvoice is true AND cartItems is null
    } else if (saleInvoiceModel.isInvoice == true) {
      displayColor = Colors.blue; // Green if only isInvoice is true
    } else {
      displayColor = Colors.red; // Red if isInvoice is false
    }

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Center(
                    child: Text(
                      ' ${DateFormat('yyyy-MM-dd').format(saleInvoiceModel.dateTime!)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: displayColor, // Apply the determined color
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 1, child: Center(child: VerticalDivider())),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Text(
                    "${saleInvoiceModel.totalOfInvoice}",
                    style: TextStyle(
                      fontSize: 12,
                      color: displayColor,
                    ),
                  ),
                ),
              ),
              Expanded(flex: 1, child: Center(child: VerticalDivider())),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Text(
                    "${saleInvoiceModel.newDebt}",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              ),
              Expanded(flex: 1, child: Center(child: VerticalDivider())),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                            InvoiceDetailsForClient(saleInvoiceModel: saleInvoiceModel,),
                      ),
                    );

                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Text(
                      "${saleInvoiceModel.invoiceNum}",
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
