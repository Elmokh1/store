import 'package:flutter/material.dart';
import '../../data/model/client_invoice_model/sale_invoice_model.dart'; // Ensure this path is correct
import 'package:intl/intl.dart';

import '../Debts/AllDebt/client_details/client_debt/invoice_details_for_client.dart'; // Ensure this path is correct

class ClientInvoiceViewWidget extends StatelessWidget {
  final SaleInvoiceModel saleInvoiceModel;

  ClientInvoiceViewWidget({required this.saleInvoiceModel});

  @override
  Widget build(BuildContext context) {
    // If the model is null, return an empty SizedBox to avoid errors.
    if (saleInvoiceModel == null) return SizedBox();

    // Determine the invoice type and corresponding colors for the card and text.
    Color baseCardColor;
    Color gradientStartColor;
    Color gradientEndColor;
    String invoiceType;
    Color invoiceTypeTextColor;

    // Logic to determine invoice type and assign colors based on your rules.
    if (saleInvoiceModel.isInvoice == true &&
        (saleInvoiceModel.cartItems == null || saleInvoiceModel.cartItems!.isEmpty)) {
      // Collection Invoice (فاتورة تحصيل)
      baseCardColor = Colors.green.shade50;
      gradientStartColor = Colors.lightGreen.shade100;
      gradientEndColor = Colors.green.shade200;
      invoiceType = "فاتورة تحصيل";
      invoiceTypeTextColor = Colors.green.shade800;
    } else if (saleInvoiceModel.isInvoice == true &&
        (saleInvoiceModel.cartItems != null && saleInvoiceModel.cartItems!.isNotEmpty)) {
      // Return Invoice (فاتورة مرتجع)
      baseCardColor = Colors.blue.shade50;
      gradientStartColor = Colors.blue.shade100;
      gradientEndColor = Colors.blue.shade200;
      invoiceType = "فاتورة مرتجع";
      invoiceTypeTextColor = Colors.blue.shade800;
    } else {
      // Sale Invoice (فاتورة بيع)
      baseCardColor = Colors.red.shade50;
      gradientStartColor = Colors.orange.shade100;
      gradientEndColor = Colors.red.shade200;
      invoiceType = "فاتورة بيع";
      invoiceTypeTextColor = Colors.red.shade800;
    }

    // Format the date for display.
    final dateFormatted = saleInvoiceModel.dateTime != null
        ? DateFormat('yyyy-MM-dd').format(saleInvoiceModel.dateTime!)
        : 'بدون تاريخ';

    return InkWell(
      onTap: () {
        // Navigate to the client invoice details page when the card is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsForClient(
              saleInvoiceModel: saleInvoiceModel,
            ),
          ),
        );
      },
      child: Card(
        // Set the background color of the card.
        color: baseCardColor,
        // Define the shape with rounded corners.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // Add a subtle shadow for depth.
        elevation: 6,
        // Set margin around the card.
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          // Apply a linear gradient background to the container inside the card.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [gradientStartColor, gradientEndColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20), // Increased padding for better spacing.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Type Badge
              Align( // Use Align to ensure the badge is always at the start.
                alignment: Alignment.centerRight, // Adjust alignment based on your UI's text direction
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: invoiceTypeTextColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10), // More rounded corners for the badge
                    boxShadow: [
                      BoxShadow(
                        color: invoiceTypeTextColor.withOpacity(0.1),
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    invoiceType,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: invoiceTypeTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Increased vertical space.

              // Invoice Number Row
              _buildInfoRow(
                context,
                Icons.receipt_long, // Icon for invoice number
                "رقم الفاتورة",
                saleInvoiceModel.invoiceNum ?? "—",
              ),
              const SizedBox(height: 8),

              // Client Name Row
              _buildInfoRow(
                context,
                Icons.person, // Icon for client name
                "اسم العميل",
                saleInvoiceModel.clientName ?? "—",
              ),
              const SizedBox(height: 8),

              // Date Row
              _buildInfoRow(
                context,
                Icons.calendar_today, // Icon for date
                "التاريخ",
                dateFormatted,
              ),
              const SizedBox(height: 8),

              // Total of Invoice Row
              _buildInfoRow(
                context,
                Icons.attach_money, // Icon for total invoice amount
                "إجمالي الفاتورة",
                "${saleInvoiceModel.totalOfInvoice ?? 0} ج.م",
              ),
              const SizedBox(height: 8),

              // Old Debt Row
              _buildInfoRow(
                context,
                Icons.account_balance_wallet_outlined, // Icon for previous debt
                "المديونية السابقة",
                "${saleInvoiceModel.oldDebt ?? 0} ج.م",
              ),
              const SizedBox(height: 8),

              // New Debt Row
              _buildInfoRow(
                context,
                Icons.trending_up, // Icon for new debt (or a relevant one)
                "المديونية الجديدة",
                "${saleInvoiceModel.newDebt ?? 0} ج.م",
              ),

              // Conditional display for cart items
              if (saleInvoiceModel.cartItems != null &&
                  saleInvoiceModel.cartItems!.isNotEmpty) ...[
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
                // Display each product as a bullet point.
                ...saleInvoiceModel.cartItems!.map(
                      (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${item.productName ?? "منتج"} (${item.qun ?? 0} ${item.productName ?? ''})",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a consistent info row with an icon, label, and value.
  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
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
            overflow: TextOverflow.ellipsis, // Handle long text.
          ),
        ),
      ],
    );
  }
}
