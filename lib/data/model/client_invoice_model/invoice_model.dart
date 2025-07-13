class ClientInvoiceModel {
  static const String collectionName = 'clientInvoiceModel';
  String? id;
  String? clientName;
  String? clientId;
  String? invoiceNum;
  double? oldDebt;
  double? payment;
  double? newDebt;
  DateTime? dateTime;
  bool? isInvoice;
  DateTime? realDateTime;

  ClientInvoiceModel({
    this.oldDebt,
    this.id,
    this.clientName,
    this.clientId,
    this.invoiceNum,
    this.payment,
    this.dateTime,
    this.realDateTime,
    this.newDebt,
    this.isInvoice = false,
  });

  ClientInvoiceModel.fromFireStore(Map<String, dynamic>? date)
      : this(
    id: date?["id"],
    oldDebt: date?["oldDebt"],
    clientName: date?["clientName"],
    clientId: date?["clientId"],
    invoiceNum: date?["invoiceNum"],
    payment: date?["payment"],
    newDebt: date?["newDebt"],
    isInvoice: date?["isInvoice"],
    dateTime: DateTime.fromMillisecondsSinceEpoch(date?["dateTime"]),
    realDateTime: DateTime.fromMillisecondsSinceEpoch(date?["dateTime"]),

  );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "oldDebt": oldDebt,
      "clientName": clientName,
      "clientId": clientId,
      "invoiceNum": invoiceNum,
      "payment": payment,
      "newDebt": newDebt,
      "isInvoice": isInvoice,
      "dateTime": dateTime?.millisecondsSinceEpoch,
      "realDateTime": realDateTime?.millisecondsSinceEpoch,
    };
  }
}
