class UserModel {
  static const String collectionName = 'users';
  String? id;
  String? email;
  String? name;
  String? password;

  UserModel({this.id, this.email, this.name, this.password});

  UserModel.fromFireStore(Map<String, dynamic>? data)
    : this(
        id: data?['id'],
        email: data?['email'],
        name: data?['name'],
        password: data?['password'],
      );

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'email': email, 'name': name, 'password': password};
  }
}
