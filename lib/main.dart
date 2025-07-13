import 'package:agri_store/ui/Debts/debts.dart';
import 'package:agri_store/ui/add_client/add_customer.dart';
import 'package:agri_store/ui/add_invoice/invoice_page.dart';
import 'package:agri_store/ui/admin/admin_screen.dart';
import 'package:agri_store/ui/admin/store_worker/store_worker.dart';
import 'package:agri_store/ui/all_invoice_view/all_invoice_page.dart';
import 'package:agri_store/ui/home_screen.dart';
import 'package:agri_store/ui/inventory/inventory_page.dart';
import 'package:agri_store/ui/login/login_screen.dart';
import 'package:agri_store/ui/register/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      initialRoute:
          AdminScreen.routeName,
          // LoginScreen.routeName,
      // StoreWorkerScreen.routeName
      //     user?.uid != null ? HomeScreen.routeName : RegisterScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        AdminScreen.routeName: (context) => AdminScreen(),
        AddClient.routeName: (context) => AddClient(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        ShowAllDebtPage.routeName: (context) => ShowAllDebtPage(),
        InvoicePage.routeName: (context) => InvoicePage(),
        InventoryPage.routeName: (context) => InventoryPage(),
        AllInvoicePage.routeName: (context) => AllInvoicePage(),
        StoreWorkerScreen.routeName: (context) => StoreWorkerScreen(),
      },
    );
  }
}
// كدا كله تمام فاضل الفواتير بس الفواتير متسجله ف اكتر من مكان لازم نلاقي طريقه حلوه نعرض بيها
// العرض عند الادمن ناقص برضو


// كدا اللي فاضل فواتير المخزن بس