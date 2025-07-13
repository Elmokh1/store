import 'package:agri_store/data/model/product_model.dart';

class SaleInvoiceModel {
  static const String collectionName = 'saleInvoiceModel';
  String? id;
  String? clientName;
  String? clientId;
  String? invoiceNum;
  double? oldDebt;
  double? totalOfInvoice;
  double? newDebt;
  DateTime? dateTime;
  DateTime? createdAt;
  List<ProductModel>? cartItems;
  bool? isInvoice;
  SaleInvoiceModel({
    this.oldDebt,
    this.id,
    this.clientName,
    this.clientId,
    this.totalOfInvoice,
    this.dateTime,
    this.createdAt,
    this.newDebt,
    this.invoiceNum,
    this.cartItems,
    this.isInvoice = false,
  });

  SaleInvoiceModel.fromFireStore(Map<String, dynamic>? data)
      : this(
    id: data?["id"],
    invoiceNum: data?["invoiceNum"],
    oldDebt: data?["oldDebt"],
    clientName: data?["clientName"],
    isInvoice: data?["isInvoice"],
    clientId: data?["clientId"],
    totalOfInvoice: data?["totalOfInvoice"],
    newDebt: data?["newDebt"],
    dateTime: DateTime.fromMillisecondsSinceEpoch(data?["dateTime"]),
    createdAt: DateTime.fromMillisecondsSinceEpoch(data?["createdAt"]),
    cartItems: (data?["cartItems"] as List<dynamic>?)
        ?.map((item) => ProductModel.fromFireStore(item))
        .toList(),
  );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "invoiceNum": invoiceNum,
      "isInvoice": isInvoice,
      "oldDebt": oldDebt,
      "clientName": clientName,
      "clientId": clientId,
      "totalOfInvoice": totalOfInvoice,
      "newDebt": newDebt,
      "dateTime": dateTime?.millisecondsSinceEpoch,
      "createdAt": createdAt?.millisecondsSinceEpoch,
      'cartItems': cartItems?.map((item) => item.toFireStore()).toList(),

    };
  }
}
