import 'package:agri_store/data/model/client_invoice_model/sale_invoice_model.dart';
import 'package:agri_store/data/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/client_model.dart';
import 'model/client_invoice_model/debt_model.dart';
import 'model/client_invoice_model/invoice_model.dart';
import 'model/main_inventory_model/main_inventory_model.dart';
import 'model/product_model.dart';

class MyDataBase {
  static CollectionReference<UserModel> getUserCollection() {
    return FirebaseFirestore.instance
        .collection(UserModel.collectionName)
        .withConverter<UserModel>(
          fromFirestore:
              (snapshot, options) => UserModel.fromFireStore(snapshot.data()),
          toFirestore: (customer, options) => customer.toFireStore(),
        );
  }

  static Future<void> addUser(UserModel user) {
    var collection = getUserCollection();
    return collection.doc(user.id).set(user);
  }

  static Future<UserModel?> readUser(String id) async {
    var collection = getUserCollection();
    var docSnapShot = await collection.doc(id).get();
    return docSnapShot.data();
  }

  static CollectionReference<ClientModel> getClientsCollection(String uId) {
    return getUserCollection()
        .doc(uId)
        .collection(ClientModel.collectionName)
        .withConverter<ClientModel>(
          fromFirestore:
              (snapshot, options) => ClientModel.fromFireStore(snapshot.data()),
          toFirestore: (client, options) => client.toFireStore(),
        );
  }

  static Future<void> addClient(String uid, ClientModel client) {
    var newClient = getClientsCollection(uid).doc();
    client.id = newClient.id;
    return newClient.set(client);
  }

  static Stream<QuerySnapshot<UserModel>> getUserRealTimeUpdate() {
    return getUserCollection().snapshots();
  }

  //Debt
  static CollectionReference<DebtModel> getDebtCollection(String uid) {
    return getUserCollection()
        .doc(uid)
        .collection(DebtModel.collectionName)
        .withConverter<DebtModel>(
          fromFirestore:
              (snapshot, options) => DebtModel.fromFireStore(snapshot.data()),
          toFirestore: (dept, options) => dept.toFireStore(),
        );
  }

  static Future<void> addDebt(String uid, DebtModel debt) {
    var newDebt = getDebtCollection(uid).doc();
    debt.id = newDebt.id;
    return newDebt.set(debt);
  }

  static Stream<QuerySnapshot<DebtModel>> getDebtRealTimeUpdate(String uId) {
    return getDebtCollection(uId).snapshots();
  }

  static Future<void> editDebt(String uId, String debtId, double oldDebt) {
    return getDebtCollection(uId).doc(debtId).update({"oldDebt": oldDebt});
  }

  //invoice
  static CollectionReference<ClientInvoiceModel>
  getClientInvoiceModelCollection(String uid, String cId) {
    return getDebtCollection(uid)
        .doc(cId)
        .collection(ClientInvoiceModel.collectionName)
        .withConverter<ClientInvoiceModel>(
          fromFirestore:
              (snapshot, options) =>
                  ClientInvoiceModel.fromFireStore(snapshot.data()),
          toFirestore:
              (clientInvoiceModel, options) => clientInvoiceModel.toFireStore(),
        );
  }

  static Future<void> addClientInvoice(
    String uid,
    ClientInvoiceModel clientInvoice,
    String cId,
  ) {
    var newClientInvoice = getClientInvoiceModelCollection(uid, cId).doc();
    clientInvoice.id = newClientInvoice.id;
    return newClientInvoice.set(clientInvoice);
  }

  static Stream<QuerySnapshot<ClientInvoiceModel>>
  getClientInvoiceRealTimeUpdate(String uId, String cId) {
    return getClientInvoiceModelCollection(uId, cId).snapshots();
  }

  // products
  static CollectionReference<ProductModel> getProductCollection() {
    return FirebaseFirestore.instance
        .collection(ProductModel.collectionName)
        .withConverter<ProductModel>(
          fromFirestore:
              (snapshot, options) =>
                  ProductModel.fromFireStore(snapshot.data()),
          toFirestore: (product, options) => product.toFireStore(),
        );
  }

  static Future<void> addProduct(ProductModel product) {
    var newProduct = getProductCollection().doc();
    product.id = newProduct.id;
    return newProduct.set(product);
  }

  static Future<ProductModel?> readProduct(String id) async {
    var collection = getProductCollection();
    var docSnapShot = await collection.doc(id).get();
    return docSnapShot.data();
  }

  static Stream<QuerySnapshot<ProductModel>> getProductRealTimeUpdate() {
    return getProductCollection().snapshots();
  }

  static Future<void> editProduct(double price) {
    return getProductCollection().doc().update({"price": price});
  }

  // inventory
  static CollectionReference<ProductModel> getProductToInventoryCollection(
    String uid,
  ) {
    return getUserCollection()
        .doc(uid)
        .collection(ProductModel.collectionName)
        .withConverter<ProductModel>(
          fromFirestore:
              (snapshot, options) =>
                  ProductModel.fromFireStore(snapshot.data()),
          toFirestore: (product, options) => product.toFireStore(),
        );
  }

  static Future<void> addProductToInventory(
    String uId,
    ProductModel product,
  ) async {
    final collection = getProductToInventoryCollection(uId);

    final querySnapshot =
        await collection.where('id', isEqualTo: product.id).get();

    if (querySnapshot.docs.isNotEmpty) {
      final existingProduct = querySnapshot.docs.first;
      final currentQun = existingProduct.data().qun ?? 0;
      final newQun = currentQun + (product.qun ?? 0);

      await collection.doc(existingProduct.id).update({'qun': newQun});
    } else {
      await collection.doc(product.id).set(product);
    }
  }

  static Future<void> subtractProductFromInventory(
    String uId,
    ProductModel product,
  ) async {
    final collection = getProductToInventoryCollection(uId);

    final querySnapshot =
        await collection.where('id', isEqualTo: product.id).get();

    if (querySnapshot.docs.isNotEmpty) {
      final existingProduct = querySnapshot.docs.first;
      final currentQun = existingProduct.data().qun ?? 0;
      final subtractQun = product.qun ?? 0;
      final newQun = currentQun - subtractQun;

      if (newQun > 0) {
        await collection.doc(existingProduct.id).update({'qun': newQun});
      } else {
        await collection.doc(existingProduct.id).delete();
      }
    } else {
      throw Exception('المنتج غير موجود في المخزن');
    }
  }

  // Buy From Main invoices

  static CollectionReference<MainInventoryInvoiceModel> getBuyInvoiceCollection(
    String userId,
  ) {
    return getUserCollection()
        .doc(userId)
        .collection(MainInventoryInvoiceModel.collectionName)
        .withConverter<MainInventoryInvoiceModel>(
          fromFirestore:
              (snapshot, options) =>
                  MainInventoryInvoiceModel.fromFireStore(snapshot.data()),
          toFirestore: (product, options) => product.toFireStore(),
        );
  }

  static Future<void> addBuyInvoice(
    String userId,
    MainInventoryInvoiceModel buyInvoice,
  ) {
    var newBuyInvoice = getBuyInvoiceCollection(userId).doc();
    buyInvoice.id = newBuyInvoice.id;
    return newBuyInvoice.set(buyInvoice);
  }

  static Future<QuerySnapshot<MainInventoryInvoiceModel>> getBuyInvoices(
    String userId,
  ) {
    return getBuyInvoiceCollection(userId).get();
  }

  static Stream<QuerySnapshot<MainInventoryInvoiceModel>>
  getBuyInvoicesRealTimeUpdate(String userId) {
    return getBuyInvoiceCollection(
      userId,
    ).orderBy("dateTime", descending: true).snapshots();
  }

  static Stream<QuerySnapshot<MainInventoryInvoiceModel>>
  getBuyInvoicesRealTimeUpdateByTime(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return getBuyInvoiceCollection(userId)
        .where(
          "dateTime",
          isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
        )
        .where("dateTime", isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy("dateTime", descending: true)
        .snapshots();
  }

  static Future<List<MainInventoryInvoiceModel>>
  getInvoicesByProductIdFirestore({
    required String userId,
    required String itemId,
  }) async {
    final snapshot =
        await getBuyInvoiceCollection(userId)
            .where("itemIds", arrayContains: itemId)
            .orderBy("dateTime", descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Return From Main invoices

  static CollectionReference<MainInventoryInvoiceModel>
  getReturnToMainCollection(String userId) {
    return getUserCollection()
        .doc(userId)
        .collection(MainInventoryInvoiceModel.collectionName)
        .withConverter<MainInventoryInvoiceModel>(
          fromFirestore:
              (snapshot, options) =>
                  MainInventoryInvoiceModel.fromFireStore(snapshot.data()),
          toFirestore: (product, options) => product.toFireStore(),
        );
  }

  static Future<void> addReturnToMain(
    String userId,
    MainInventoryInvoiceModel returnToMain,
  ) {
    var newReturnToMain = getReturnToMainCollection(userId).doc();
    returnToMain.id = newReturnToMain.id;
    return newReturnToMain.set(returnToMain);
  }

  //Sale Invoice
  static CollectionReference<SaleInvoiceModel> getSaleInvoiceCollection(
    String userId,
  ) {
    return getUserCollection()
        .doc(userId)
        .collection(SaleInvoiceModel.collectionName)
        .withConverter<SaleInvoiceModel>(
          fromFirestore:
              (snapshot, options) =>
                  SaleInvoiceModel.fromFireStore(snapshot.data()),
          toFirestore: (product, options) => product.toFireStore(),
        );
  }

  static Future<void> addSaleInvoice(
    String userId,
    SaleInvoiceModel saleInvoice,
  ) {
    var newSaleInvoice = getSaleInvoiceCollection(userId).doc();
    saleInvoice.id = newSaleInvoice.id;
    return newSaleInvoice.set(saleInvoice);
  }

  static Future<QuerySnapshot<SaleInvoiceModel>> getSaleInvoice(String userId) {
    return getSaleInvoiceCollection(userId).get();
  }

  static Stream<QuerySnapshot<SaleInvoiceModel>> getSaleInvoiceRealTimeUpdate(
    String userId,
  ) {
    return getSaleInvoiceCollection(
      userId,
    ).orderBy("dateTime", descending: false).snapshots();
  }

  static Stream<QuerySnapshot<SaleInvoiceModel>> getSaleInvoiceForClientRealTimeUpdate(
      String userId,
      clientId,
      ) {
    return getSaleInvoiceCollection(
      userId,
    ).where("clientId", isEqualTo: clientId).orderBy("dateTime", descending: false).snapshots();
  }
  static Stream<QuerySnapshot<SaleInvoiceModel>>
  getSaleInvoiceRealTimeUpdateByDateTime(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return getSaleInvoiceCollection(userId)
        .where(
          "dateTime",
          isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
        )
        .where("dateTime", isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy("dateTime", descending: false)
        .snapshots();
  }
}
