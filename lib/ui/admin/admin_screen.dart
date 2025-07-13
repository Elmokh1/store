import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assuming these models exist and paths are correct
import '../../data/model/product_model.dart';
import '../../data/model/user_model.dart';
import '../../data/my_database.dart';
import 'client_widget.dart'; // Assuming MyDataBase has addProduct and getUserRealTimeUpdate

class AdminScreen extends StatefulWidget {
  static const String routeName = "AdminScreen";

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
            // Stretch children horizontally
            children: [
              // Add Product Button
              ElevatedButton.icon(
                onPressed: () => _showAddProductBottomSheet(context),
                icon: const Icon(Icons.add_shopping_cart, size: 24),
                label: const Text(
                  "إضافة منتج جديد", // Add New Product
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  // Use accent color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
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
                          child: ClientListItem(client: client),
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

  void _showAddProductBottomSheet(BuildContext context) {
    _productNameController.clear(); // Clear previous input
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows keyboard to push content up
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Form(
            key: _addProductFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "إضافة منتج جديد", // Add New Product
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: "اسم المنتج",
                    // Product Name
                    hintText: "أدخل اسم المنتج",
                    // Enter product name
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "الرجاء إدخال اسم المنتج"; // Please enter product name
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _addProduct();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "حفظ المنتج", // Save Product
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10), // Padding below the button
              ],
            ),
          ),
        );
      },
    );
  }

  void _addProduct() async {
    if (_addProductFormKey.currentState?.validate() == true) {
      try {
        ProductModel product = ProductModel(
          productName: _productNameController.text.trim(),
          qun: 0, // Assuming initial quantity is 0
        );
        await MyDataBase.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة المنتج بنجاح!'),
          ), // Product added successfully!
        );
        _productNameController.clear();
        Navigator.pop(context); // Close the bottom sheet
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة المنتج: ${e.message}'),
          ), // Error adding product
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: $e'),
          ), // An unexpected error occurred
        );
      }
    }
  }
}
