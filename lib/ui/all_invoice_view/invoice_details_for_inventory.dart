import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// Assuming MainInventoryInvoiceModel and ProductModel are defined in these files.
// You might need to adjust the import paths based on your project structure.
import 'package:agri_store/data/model/product_model.dart';

import '../../data/model/main_inventory_model/main_inventory_model.dart';


class InvoiceDetailsForInventory extends StatelessWidget {
  final MainInventoryInvoiceModel mainInventoryInvoice;

  const InvoiceDetailsForInventory({super.key, required this.mainInventoryInvoice});

  @override
  Widget build(BuildContext context) {
    // Determine invoice type, title, color, and icon
    final bool isReturn = mainInventoryInvoice.isReturn ?? false;
    final String title = isReturn ? "فاتورة مرتجع" : "فاتورة شراء";
    final Color primaryColor = isReturn ? Colors.blue.shade700 : Colors.red.shade700;
    final IconData headerIcon = isReturn ? Icons.replay_circle_filled_rounded : Icons.receipt_long_rounded;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Card ---
              _buildHeaderCard(context, headerIcon, primaryColor, title),
              const SizedBox(height: 20),

              // --- Products Card ---
              if (mainInventoryInvoice.cartItems?.isNotEmpty ?? false)
                _buildProductsCard(context)
              else
                const Center(child: Text("لا توجد منتجات في هذه الفاتورة")),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header card with invoice number and date.
  Widget _buildHeaderCard(BuildContext context, IconData icon, Color color, String title) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(
              icon: Icons.numbers_rounded,
              label: 'رقم الفاتورة:',
              value: mainInventoryInvoice.invoiceNum ?? 'غير محدد',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'تاريخ الإنشاء:',
              value: DateFormat('dd-MM-yyyy').format(mainInventoryInvoice.dateTime!),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the card that lists all products in the invoice.
  Widget _buildProductsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures content respects the border radius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Table Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text('المنتج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                ),
                Expanded(
                  flex: 1,
                  child: Text('الكمية', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // --- Products List ---
          ListView.separated(
            itemCount: mainInventoryInvoice.cartItems!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // The parent is already scrollable
            itemBuilder: (context, index) {
              final item = mainInventoryInvoice.cartItems![index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.productName ?? 'منتج غير معروف',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${item.qun}',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method for creating a consistent row with an icon, label, and value.
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
