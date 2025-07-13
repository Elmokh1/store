import 'package:agri_store/logic/return_invoice/return_invoice_cubit.dart';
import 'package:agri_store/ui/add_invoice/main_inventory/add_to_inventory_page.dart';
import 'package:flutter/material.dart';
import 'package:agri_store/ui/add_invoice/return_invoice_page.dart';
import 'package:agri_store/ui/add_invoice/sale_invoice_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/sale_invoice/sale_invoice_cubit.dart';
import 'collection_invoice_page.dart';
import 'main_inventory/return_to_main_inventory.dart';

class InvoicePage extends StatefulWidget {
  static const routeName = 'invoice';
  final String? uId;
  final bool? isStoreWorker;

  InvoicePage({super.key, this.uId, this.isStoreWorker});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    final bool isWorker = widget.isStoreWorker == true;

    final allCards = <Widget>[
      if (!isWorker)
        _buildInvoiceTypeCard(
          context,
          'فاتورة بيع',
          Icons.shopping_cart,
          Colors.green[600]!,
              () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BlocProvider(
                        create: (_) => SaleInvoiceCubit(),
                        child: SaleInvoicePage(uId: widget.uId),
                      ),
                ),
              ),
        ),
      if (!isWorker)
        _buildInvoiceTypeCard(
          context,
          'اذن تحصيل',
          Icons.payments,
          Colors.blue[600]!,
              () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CollectionInvoicePage(uId: widget.uId),
                ),
              ),
        ),
      if (!isWorker)
        _buildInvoiceTypeCard(
          context,
          'مرتجع من العميل',
          Icons.receipt_long,
          Colors.orange[600]!,
              () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BlocProvider(
                          create:(_) => ReturnInvoiceCubit(),

                          child: ReturnInvoicePage(uId: widget.uId)),

                ),
              ),
        ),
      if (isWorker)
        _buildInvoiceTypeCard(
          context,
          'اضافة للمخزن',
          Icons.add_box,
          Colors.purple[600]!,
              () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddToInventoryPage(uId: widget.uId),
                ),
              ),
        ),
      if (isWorker)
        _buildInvoiceTypeCard(
          context,
          'مرتجع الي المخزن',
          Icons.inventory_2,
          Colors.red[600]!,
              () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReturnToMainInvoicePage(uId: widget.uId),
                ),
              ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر نوع الفاتورة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الرجاء اختيار نوع الفاتورة من القائمة التالية:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: allCards,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceTypeCard(BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: color,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
