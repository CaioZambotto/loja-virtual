import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/models/address.dart';

class Users {

  Users({this.email, this.password,this.name,this.confirmPassword,this.id});

  String? id;
  String? name;
  String? email;
  String? password;
  String? confirmPassword;

  bool admin = false;

  Address? address;

  DocumentReference get firestoreRef => FirebaseFirestore.instance.collection('users').doc(id);

  Users.fromDocument(DocumentSnapshot document){
    id = document.id;
    name = document['name'] as String;
    email = document['email'] as String;

    Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;

    if (dataMap.containsKey('address')) {
      address = Address.fromMap(document['address'] as Map<String, dynamic>);
    }
  }

  CollectionReference get cartReference =>
      firestoreRef.collection('cart');

  Future<void> saveData() async {
    await firestoreRef.set(toMap());
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'email': email,
      if(address != null)
        'address': address!.toMap(),
    };
  }

  void setAddress(Address address){
    this.address = address;
    saveData();
  }

}

