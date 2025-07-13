class ProductModel {
  static const String collectionName = 'products';
  String? id;
  String? productName;
  int? qun;
  double?price;
  double?total;

  ProductModel({
    this.id,
    this.productName,
    this.qun,
    this.price = 0,
    this.total = 0,
  });
  ProductModel.fromFireStore(Map<String, dynamic>? date)
      : this(
    id: date?["id"],
    productName: date?["productName"],
    qun: date?["qun"],
    price: date?["price"],
    total: date?["total"],
  );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "productName": productName,
      "qun": qun,
      "price": price,
      "total": total,
    };
  }
}
