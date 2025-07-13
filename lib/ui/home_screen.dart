import 'package:agri_store/ui/add_client/add_customer.dart';
import 'package:agri_store/ui/add_invoice/invoice_page.dart';
import 'package:agri_store/ui/all_invoice_view/all_invoice_page.dart';
import 'package:agri_store/ui/inventory/inventory_page.dart';
import 'package:agri_store/ui/Debts/debts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'HomeScreen';
  final bool? isLoggedIn;
  final bool? isStoreWorker;
  final String? uId;

  HomeScreen({
    super.key,
    this.isLoggedIn = true,
    this.isStoreWorker = false,
    this.uId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeItem {
  final String title;
  final IconData icon;
  final Widget Function(String? userId) builder;

  _HomeItem({required this.title, required this.icon, required this.builder});
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  String? _getUserIdToSend() {
    if (widget.isLoggedIn == true) {
      return _currentUser?.uid;
    }
    return widget.uId;
  }

  List<_HomeItem> _buildHomeItems(String? userId) {
    if (widget.isStoreWorker == true) {
      // لو عامل مخزن
      return [
        _HomeItem(
          title: 'إضافة فاتورة',
          icon: Icons.receipt_long,
          builder: (userId) => InvoicePage(uId: userId,isStoreWorker: true,),
        ),
        _HomeItem(
          title: 'الفواتير',
          icon: Icons.description,
          builder: (userId) => AllInvoicePage(uId: userId,isStoreWorker: true,),
        ),
      ];
    } else {
      // لو مش عامل مخزن (يعني مدير مثلاً)
      return [
        _HomeItem(
          title: 'إضافة عميل',
          icon: Icons.person_add,
          builder: (userId) => AddClient(uId: userId),
        ),
        _HomeItem(
          title: 'إضافة فاتورة',
          icon: Icons.receipt_long,
          builder: (userId) => InvoicePage(uId: userId),
        ),
        _HomeItem(
          title: 'المخزن',
          icon: Icons.store_mall_directory,
          builder: (userId) => InventoryPage(uId: userId),
        ),
        _HomeItem(
          title: 'المديونيات',
          icon: Icons.money_off_csred,
          builder: (userId) => ShowAllDebtPage(uId: userId),
        ),
        _HomeItem(
          title: 'الفواتير',
          icon: Icons.description,
          builder: (userId) => AllInvoicePage(uId: userId),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userIdToSend = _getUserIdToSend();
    final items = _buildHomeItems(userIdToSend);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'الرئيسية',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                print(userIdToSend);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => item.builder(userIdToSend),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 52, color: Colors.teal[700]),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
