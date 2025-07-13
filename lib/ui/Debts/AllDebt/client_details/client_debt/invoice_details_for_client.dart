import 'package:flutter/material.dart';

import 'package:agri_store/data/model/product_model.dart'; // Import for ProductModel
import 'package:agri_store/data/model/client_invoice_model/sale_invoice_model.dart';
import 'package:intl/intl.dart'; // Import for SaleInvoiceModel
import 'dart:ui' as ui;

class InvoiceDetailsForClient extends StatelessWidget {
  final SaleInvoiceModel saleInvoiceModel;

  InvoiceDetailsForClient({required this.saleInvoiceModel});

  @override
  Widget build(BuildContext context) {
    String text;
    Color invoiceColor;

    if (saleInvoiceModel.isInvoice == true && saleInvoiceModel.cartItems == null) {
      text = "تحصيل";
      invoiceColor=Colors.green;
    } else if (saleInvoiceModel.isInvoice == true) {
      text = "مرتجع";
      invoiceColor=Colors.blue;    } else {
      text = "شراء";
      invoiceColor=Colors.red;    }

    final Color totalInvoiceColor = Colors.green; // Default to green for invoice totals

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: invoiceColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                    children: [
                      // --- Invoice Header Section ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'رقم الفاتورة: ${saleInvoiceModel.invoiceNum ?? 'غير محدد'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'اسم العميل: ${saleInvoiceModel.clientName ?? 'غير محدد'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'تاريخ الإنشاء: ${DateFormat('dd-MM-yyyy').format(saleInvoiceModel.dateTime!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (saleInvoiceModel.cartItems != null && saleInvoiceModel.cartItems!.isNotEmpty)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المنتجات المضافة:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 25, // Adjust spacing for better fit
                            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                            columns: const [
                              DataColumn(label: Text('اسم المنتج')),
                              DataColumn(label: Text('العدد')),
                              DataColumn(label: Text('السعر')),
                              DataColumn(label: Text('الإجمالي')),
                            ],
                            rows: saleInvoiceModel.cartItems!
                                .map(
                                  (item) => DataRow(
                                cells: [
                                  DataCell(Text(item.productName ?? '')),
                                  DataCell(Text(item.qun?.toString() ?? '0')),
                                  DataCell(Text(item.price?.toStringAsFixed(2) ?? '0.00')),
                                  DataCell(Text(item.total?.toStringAsFixed(2) ?? '0.00')),
                                ],
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
              const SizedBox(height: 20),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFinancialRow('المديونية القديمة:', '${saleInvoiceModel.oldDebt?.toStringAsFixed(2) ?? '0.00'} ج', Colors.grey[700]!),
                      const SizedBox(height: 10),
                      _buildFinancialRow('إجمالي الفاتورة:', '${saleInvoiceModel.totalOfInvoice?.toStringAsFixed(2) ?? '0.00'} ج', invoiceColor, isBold: true),
                      const SizedBox(height: 10),
                      _buildFinancialRow('المديونية الجديدة:', '${saleInvoiceModel.newDebt?.toStringAsFixed(2) ?? '0.00'} ج', Colors.black, isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent financial detail rows
  Widget _buildFinancialRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
