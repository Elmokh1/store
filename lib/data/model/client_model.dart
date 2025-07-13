class ClientModel {
  static const String collectionName = 'clients';
  String? id;
  String? address;
  String? name;
  String? phone;

  ClientModel({this.id, this.address, this.name, this.phone});

  ClientModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        address: data?['address'],
        name: data?['name'],
        phone: data?['phone'],
      );

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'address': address, 'name': name, 'phone': phone};
  }
}
