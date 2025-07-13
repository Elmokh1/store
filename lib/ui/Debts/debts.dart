import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/model/client_invoice_model/debt_model.dart';
import '../../data/my_database.dart';
import 'AllDebt/debt_item_widget.dart';

class ShowAllDebtPage extends StatefulWidget {
  static const String routeName = "ShowAllDebtPage";

  String? uId;

  ShowAllDebtPage({this.uId});

  @override
  State<ShowAllDebtPage> createState() => _ShowAllDebtPageState();
}

class _ShowAllDebtPageState extends State<ShowAllDebtPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<DebtModel>> searchStream;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchStream = MyDataBase.getDebtRealTimeUpdate(widget.uId ?? "");
  }

  void handleSearch() {
    if (searchQuery.trim().isNotEmpty) {
      // بحث باسم العميل مع تمييز البداية والنهاية
      searchStream =
          MyDataBase.getDebtCollection(widget.uId ?? "")
              .where('clientName', isGreaterThanOrEqualTo: searchQuery)
              .where('clientName', isLessThanOrEqualTo: searchQuery + '\uf8ff')
              .snapshots();
    } else {
      searchStream = MyDataBase.getDebtRealTimeUpdate(widget.uId ?? "");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet_outlined),
            SizedBox(width: 8),
            Text('عرض جميع المديونيات'),
          ],
        ),
        backgroundColor: Colors.teal,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "بحث باسم العميل",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                handleSearch();
                              });
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  handleSearch();
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money, size: 18, color: Colors.teal),
                        SizedBox(width: 6),
                        Text(
                          "المديونية",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(thickness: 1),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.teal,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "اسم العميل",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<DebtModel>>(
              stream: searchStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final debtList =
                    snapshot.data?.docs.map((doc) => doc.data()).toList();

                if (debtList == null || debtList.isEmpty) {
                  return Center(
                    child: Text(
                      "لا توجد مديونيات حالياً",
                      style: GoogleFonts.abel(fontSize: 26, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: debtList.length,
                  itemBuilder: (context, index) {
                    final debt = debtList[index];
                    return DebtItem(debtModel: debt, uId: widget.uId ?? "");
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
