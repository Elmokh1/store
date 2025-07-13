class DebtModel {
  static const String collectionName = 'debt';
  String? id;
  String? clientName;
  double? oldDebt;

  DebtModel({
    this.oldDebt,
    this.id,
    this.clientName,
  });

  DebtModel.fromFireStore(Map<String, dynamic>? date)
      : this(
    id: date?["id"],
    oldDebt: date?["oldDebt"],
    clientName: date?["clientName"],
  );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "oldDebt": oldDebt,
      "clientName": clientName,
    };
  }
}
