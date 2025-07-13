import 'package:agri_store/data/model/main_inventory_model/main_inventory_model.dart';
import 'package:agri_store/ui/all_invoice_view/invoice_details_for_inventory.dart'; // Assuming this import is correct
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryInvoicesWidget extends StatelessWidget {
  final MainInventoryInvoiceModel inventoryInvoiceModel;

  InventoryInvoicesWidget({required this.inventoryInvoiceModel});

  @override
  Widget build(BuildContext context) {
    // If the model is null, return an empty SizedBox to avoid errors.
    if (inventoryInvoiceModel == null) return SizedBox();

    // Determine the invoice type and corresponding colors for the card and text.
    Color baseCardColor;
    Color gradientStartColor;
    Color gradientEndColor;
    String invoiceType;
    Color invoiceTypeTextColor;

    if (inventoryInvoiceModel.isReturn == true) {
      // Colors for return invoices (shades of blue)
      baseCardColor = Colors.blue.shade50;
      gradientStartColor = Colors.blue.shade100;
      gradientEndColor = Colors.blue.shade200;
      invoiceType = "فاتورة مرتجع";
      invoiceTypeTextColor = Colors.blue.shade800;
    } else {
      // Colors for sale invoices (shades of red/orange)
      baseCardColor = Colors.red.shade50;
      gradientStartColor = Colors.orange.shade100;
      gradientEndColor = Colors.red.shade200;
      invoiceType = "فاتورة بيع";
      invoiceTypeTextColor = Colors.red.shade800;
    }

    // Format the date for display.
    final dateFormatted = inventoryInvoiceModel.dateTime != null
        ? DateFormat('yyyy-MM-dd').format(inventoryInvoiceModel.dateTime!)
        : 'بدون تاريخ';

    return InkWell(
      onTap: () {
        // Navigate to the invoice details page when the card is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsForInventory(
              mainInventoryInvoice: inventoryInvoiceModel,
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
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              const SizedBox(height: 16), // Increased vertical space.

              // Invoice Number Row
              _buildInfoRow(
                context,
                Icons.receipt_long, // Icon for invoice number
                "رقم الفاتورة",
                inventoryInvoiceModel.invoiceNum ?? "—",
              ),
              const SizedBox(height: 8),

              // Date Row
              _buildInfoRow(
                context,
                Icons.calendar_today, // Icon for date
                "التاريخ",
                dateFormatted,
              ),

              // Conditional display for cart items
              if (inventoryInvoiceModel.cartItems != null &&
                  inventoryInvoiceModel.cartItems!.isNotEmpty) ...[
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
                ...inventoryInvoiceModel.cartItems!.map(
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
