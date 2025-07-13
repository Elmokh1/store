import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore QuerySnapshot
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth

// Assuming these are the correct paths to your data models and database utility
import '../../MyDateUtils.dart'; // Import for date formatting
import '../../data/model/client_invoice_model/debt_model.dart'; // Import for DebtModel
import '../../data/model/client_invoice_model/sale_invoice_model.dart';
import '../../data/my_database.dart'; // Import for MyDataBase methods
import 'package:agri_store/data/model/client_invoice_model/invoice_model.dart'; // Import for ClientInvoiceModel

class CollectionInvoicePage extends StatefulWidget {
  String? uId;

  CollectionInvoicePage({this.uId});

  @override
  State<CollectionInvoicePage> createState() => _CollectionInvoicePageState();
}

class _CollectionInvoicePageState extends State<CollectionInvoicePage> {
  final TextEditingController invoiceNumController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Variables for client selection, similar to SaleInvoicePage
  DebtModel? selectedClient;
  String? selectedClientId;
  final TextEditingController clientNameController =
      TextEditingController(); // To display selected client name
  final TextEditingController clientIdController =
      TextEditingController(); // To store selected client ID

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    invoiceNumController.dispose();
    amountController.dispose();
    clientNameController.dispose();
    clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اذن تحصيل',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        // Consistent app bar color
        iconTheme: const IconThemeData(color: Colors.white),
        // Consistent icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'حفظ التحصيل',
            onPressed: saveCollection, // Call the new saveCollection method
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // Right-to-left direction for Arabic
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16), // Consistent padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  // Updated borderRadius and elevation for consistency
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: invoiceNumController,
                          decoration: InputDecoration(
                            labelText: 'رقم الفاتورة',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Consistent border radius
                            ),
                            prefixIcon: Icon(
                              Icons.confirmation_number,
                            ), // Added icon
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        // Consistent spacing
                        // StreamBuilder for client selection DropdownButtonFormField
                        StreamBuilder<QuerySnapshot<DebtModel>>(
                          stream: MyDataBase.getDebtRealTimeUpdate(widget.uId??""),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('حدث خطأ أثناء تحميل العملاء');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final clientList =
                                snapshot.data?.docs.map((doc) {
                                  final data = doc.data();
                                  data.id = doc.id; // Set document ID to model
                                  return data;
                                }).toList() ??
                                [];

                            return DropdownButtonFormField<String>(
                              value: selectedClientId,
                              decoration: InputDecoration(
                                labelText: 'اسم العميل',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // Consistent border radius
                                ),
                                prefixIcon: Icon(Icons.person), // Added icon
                              ),
                              items:
                                  clientList.map((client) {
                                    return DropdownMenuItem<String>(
                                      value: client.id,
                                      child: Text(client.clientName ?? ""),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedClientId = value;
                                  selectedClient = clientList.firstWhere(
                                    (c) => c.id == value,
                                  );
                                  clientNameController.text =
                                      selectedClient!.clientName ?? "";
                                  clientIdController.text =
                                      selectedClient!.id ?? "";
                                });
                              },
                              hint: Text(
                                clientList.isNotEmpty
                                    ? 'اختر عميل'
                                    : 'لا يوجد عملاء',
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Consistent spacing
                        // Date selection row, similar to SaleInvoicePage
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'تاريخ التحصيل:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            InkWell(
                              onTap: showTaskDatePicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  MyDateUtils.formatTaskDate(selectedDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Spacing before amount field
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'المبلغ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Consistent border radius
                            ),
                            prefixIcon: Icon(Icons.attach_money), // Added icon
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Consistent spacing
                ElevatedButton.icon(
                  onPressed: saveCollection,
                  // Call the new saveCollection method
                  icon: const Icon(Icons.save, color: Colors.white),
                  // Icon for save button
                  label: const Text(
                    'حفظ التحصيل',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    // Consistent button color
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ), // Consistent button border radius
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to show date picker, similar to SaleInvoicePage
  void showTaskDatePicker() async {
    var date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[700], // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;
    setState(() {
      selectedDate = date;
    });
  }

  // Function to handle saving the collection invoice
  void saveCollection() async {
    // Changed to async as it will perform await operations
    if (selectedClient == null || clientNameController.text.isEmpty) {
      _showSnackBar('الرجاء اختيار العميل أولاً', Colors.orange);
      return;
    }
    if (invoiceNumController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال رقم الفاتورة', Colors.orange);
      return;
    }
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null ||
        double.parse(amountController.text) <= 0) {
      _showSnackBar('الرجاء إدخال مبلغ تحصيل صحيح وموجب', Colors.orange);
      return;
    }

    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text(
              'جاري حفظ التحصيل...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(minutes: 1), // Indefinite duration
      ),
    );

    try {
      String uId = widget.uId??"";
      double collectedAmount = double.parse(amountController.text);
      double oldDebt = selectedClient!.oldDebt ?? 0.0;
      double newDebt =
          oldDebt -
          collectedAmount; // Subtracting collected amount from old debt

      SaleInvoiceModel saleInvoiceModel = SaleInvoiceModel(
        oldDebt: oldDebt,
        newDebt: newDebt,
        clientId: selectedClientId,
        clientName: selectedClient!.clientName,
        dateTime: selectedDate,
        // The selected date from date picker
        createdAt: DateTime.now(),
        // Actual time of saving
        isInvoice: true,
        // As requested, always true for this type of transaction
        totalOfInvoice: collectedAmount,
        // The collected amount is the payment
        invoiceNum: invoiceNumController.text, // Include invoice number
      );

      // Save collection details to client invoices
      await MyDataBase.addSaleInvoice(uId, saleInvoiceModel);
      // Update client's debt in the Debt collection
      await MyDataBase.editDebt(uId, selectedClientId!, newDebt);

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
      _showSnackBar('تم حفظ التحصيل بنجاح!', Colors.green);
      _resetPage(); // Clear all fields and reset state
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading
      _showSnackBar('حدث خطأ أثناء حفظ التحصيل: ${e.toString()}', Colors.red);
      print('Error saving collection: $e'); // Log the error for debugging
    }
  }

  void _resetPage() {
    setState(() {
      invoiceNumController.clear();
      amountController.clear();
      clientNameController.clear();
      clientIdController.clear();
      selectedClient = null;
      selectedClientId = null;
      selectedDate = DateTime.now();
    });
  }

  // Helper function for showing SnackBars
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
