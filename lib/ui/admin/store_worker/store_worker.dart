import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/model/product_model.dart';
import '../../../data/model/user_model.dart';
import '../../../data/my_database.dart';
import '../client_widget.dart';


class StoreWorkerScreen extends StatefulWidget {
  static const String routeName = "StoreWorkerScreen";

  @override
  State<StoreWorkerScreen> createState() => _StoreWorkerScreenState();
}

class _StoreWorkerScreenState extends State<StoreWorkerScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final GlobalKey<FormState> _addProductFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "لوحة الإدارة", // Admin Panel in Arabic
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor:
        Theme.of(context).primaryColor, // Use theme primary color
        elevation: 0, // Remove shadow for a flat look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24), // Increased spacing
              // Clients List Header
              Text(
                "قائمة المهندسين:", // Clients List
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Clients List StreamBuilder
              Expanded(
                child: StreamBuilder<QuerySnapshot<UserModel>>(
                  stream: MyDataBase.getUserRealTimeUpdate(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء تحميل العملاء: ${snapshot.error}',
                          // Error loading clients
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final clientList =
                        snapshot.data?.docs.map((doc) {
                          final data = doc.data();
                          data.id = doc.id; // Set document ID to model
                          return data;
                        }).toList() ??
                            [];

                    if (clientList.isEmpty) {
                      return const Center(
                        child: Text(
                          "لا يوجد عملاء لعرضهم.", // No clients to display.
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: clientList.length,
                      itemBuilder: (context, index) {
                        UserModel client = clientList[index];
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: ClientListItem(client: client, isStoreWorker: true),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---


}
