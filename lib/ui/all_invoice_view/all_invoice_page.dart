import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'client_invoices_widget.dart';
import 'store_invoices_widget.dart';

class AllInvoicePage extends StatefulWidget {
  static const String routeName = "AllInvoicePage";

  final String? uId;
  final bool? isStoreWorker;

  AllInvoicePage({this.uId, this.isStoreWorker});

  @override
  _AllInvoicePageState createState() => _AllInvoicePageState();
}

class _AllInvoicePageState extends State<AllInvoicePage> {
  String selectedScreen = 'client';
  bool showResult = false;
  DateTime? startDate;
  DateTime? endDate;

  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    if (widget.isStoreWorker == true) {
      selectedScreen = 'store';
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(start: now.subtract(Duration(days: 7)), end: now),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool isStoreOnly = widget.isStoreWorker == true;

    return Scaffold(
      appBar: AppBar(
        title: Text("كل الفواتير"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: "فلترة بالتاريخ",
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: Icon(Icons.clear),
            tooltip: "إلغاء الفلتر",
            onPressed: _clearDateFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'من ${_formatDate(startDate)} إلى ${_formatDate(endDate)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          if (!isStoreOnly)
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('فواتير العملاء'),
                    value: 'client',
                    groupValue: selectedScreen,
                    onChanged: (value) {
                      setState(() {
                        selectedScreen = value!;
                        showResult = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('فواتير المخزن'),
                    value: 'store',
                    groupValue: selectedScreen,
                    onChanged: (value) {
                      setState(() {
                        selectedScreen = value!;
                        showResult = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showResult = true;
              });
            },
            child: Text("عرض النتائج"),
          ),
          Expanded(
            child: showResult
                ? (selectedScreen == 'client'
                ? ClientInvoicesWidget(
              startDate: startDate,
              endDate: endDate,
              isFiltered: startDate != null && endDate != null,
              uId: widget.uId ?? user?.uid ?? '',
            )
                : StoreInvoicesWidget(
              startDate: startDate,
              endDate: endDate,
              isFiltered: startDate != null && endDate != null,
              uId: widget.uId ?? user?.uid ?? '',
            ))
                : Center(
              child: Text("اختر نوع الفاتورة واضغط 'عرض النتائج'"),
            ),
          ),
        ],
      ),
    );
  }
}
