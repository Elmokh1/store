import 'package:agri_store/data/model/product_model.dart';

class MainInventoryInvoiceModel {
  static const String collectionName = 'Main';

  String? id;
  String? invoiceNum;
  List<ProductModel>? cartItems;
  DateTime? dateTime;
  bool? isReturn;
  List<String>? itemIds;
  MainInventoryInvoiceModel({
    this.id,
    this.invoiceNum,
    this.cartItems,
    this.dateTime,
    this.isReturn,
    this.itemIds,
  });

  factory MainInventoryInvoiceModel.fromFireStore(Map<String, dynamic>? data) {
    return MainInventoryInvoiceModel(
      id: data?["id"],
      isReturn: data?["isReturn"],
      invoiceNum: data?["invoiceNum"],
      itemIds: (data?["itemIds"] as List<dynamic>?)?.cast<String>(),
      cartItems: (data?["cartItems"] as List<dynamic>?)
          ?.map((item) => ProductModel.fromFireStore(item))
          .toList(),

      dateTime: data?["dateTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(data!["dateTime"])
          : null,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'isReturn': isReturn,
      'invoiceNum': invoiceNum,
      'itemIds': cartItems?.map((item) => item.id).toList(),
      'cartItems': cartItems?.map((item) => item.toFireStore()).toList(),
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }
}
