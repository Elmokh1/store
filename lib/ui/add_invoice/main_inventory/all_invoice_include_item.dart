import 'package:agri_store/data/model/main_inventory_model/main_inventory_model.dart';
import 'package:agri_store/ui/all_invoice_view/invoice_details_for_inventory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllInvoiceIncludeItem extends StatelessWidget {
  final List<MainInventoryInvoiceModel> inventoryInvoiceModel;

  AllInvoiceIncludeItem({required this.inventoryInvoiceModel});

  @override
  Widget build(BuildContext context) {
    if (inventoryInvoiceModel.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("فواتير المنتج")),
        body: Center(child: Text("لا توجد فواتير لهذا المنتج")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("فواتير المنتج")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inventoryInvoiceModel.length,
        itemBuilder: (context, index) {
          final invoice = inventoryInvoiceModel[index];

          final bool isReturn = invoice.isReturn ?? false;
          final String invoiceType = isReturn ? "فاتورة مرتجع" : "فاتورة شراء";

          final Color baseCardColor = isReturn ? Colors.blue.shade50 : Colors.red.shade50;
          final Color gradientStartColor = isReturn ? Colors.blue.shade100 : Colors.orange.shade100;
          final Color gradientEndColor = isReturn ? Colors.blue.shade200 : Colors.red.shade200;
          final Color invoiceTypeTextColor = isReturn ? Colors.blue.shade800 : Colors.red.shade800;

          final dateFormatted = invoice.dateTime != null
              ? DateFormat('yyyy-MM-dd').format(invoice.dateTime!)
              : 'بدون تاريخ';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceDetailsForInventory(mainInventoryInvoice: invoice),
                ),
              );
            },
            child: Card(
              color: baseCardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [gradientStartColor, gradientEndColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: invoiceTypeTextColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        invoiceType,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: invoiceTypeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // رقم الفاتورة
                    _buildInfoRow(context, Icons.receipt_long, "رقم الفاتورة", invoice.invoiceNum ?? "—"),
                    const SizedBox(height: 8),

                    // التاريخ
                    _buildInfoRow(context, Icons.calendar_today, "التاريخ", dateFormatted),

                    // المنتجات
                    if (invoice.cartItems != null && invoice.cartItems!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: Colors.white70, thickness: 1),
                      ),
                      Text(
                        "المنتجات:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...invoice.cartItems!.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${item.productName ?? "منتج"} (${item.qun ?? 0})",
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 10),
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
