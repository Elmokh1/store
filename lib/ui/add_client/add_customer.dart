import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../componant/custom_text_field.dart';
import '../../data/model/client_invoice_model/debt_model.dart';
import '../../data/my_database.dart';
import '../../dialog_utils.dart';

class AddClient extends StatefulWidget {
  static const String routeName = "AddClient";
  String? uId;
  AddClient({super.key, this.uId});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController oldDebtController = TextEditingController(text: "0");

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;



  @override
  void dispose() {
    clientNameController.dispose();
    oldDebtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عميل'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Text(
                'إضافة عميل جديد',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextFormField(
                Label: 'اسم العميل',
                controller: clientNameController,
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'يرجى إدخال اسم العميل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                Label: "المديونية (رقم)",
                controller: oldDebtController,
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'يرجى إدخال قيمة المديونية';
                  }
                  final value = double.tryParse(text);
                  if (value == null) {
                    return 'يرجى إدخال رقم صالح';
                  }
                  if (value < 0) {
                    return 'لا يمكن أن تكون المديونية سالبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : addClient,
                child: isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Text('إضافة العميل', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addClient() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    DialogUtils.showLoadingDialog(context, 'جاري الإضافة...');

    try {
      double oldDebt = double.parse(oldDebtController.text);

      DebtModel debtModel = DebtModel(
        clientName: clientNameController.text.trim(),
        oldDebt: oldDebt,
      );

      await MyDataBase.addDebt(widget.uId ?? "", debtModel);

      DialogUtils.hideDialog(context);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إضافة العميل بنجاح")),
      );

      Navigator.pop(context);
    } catch (e) {
      DialogUtils.hideDialog(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الإضافة: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
