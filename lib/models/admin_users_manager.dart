import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/models/user_manager.dart';

class AdminUsersManager extends ChangeNotifier{

  List<Users> users = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  void updateUser(UserManager userManager){
    _subscription?.cancel();
    if(userManager.adminEnabled){
      _listenToUsers();
    } else {
      users.clear();
      notifyListeners();
    }
  }

  void _listenToUsers(){
    _subscription = firestore.collection('users').snapshots()
        .listen((snapshot){
      users = snapshot.docs.map((d) => Users.fromDocument(d)).toList();
      users.sort((a, b) =>
          a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
      notifyListeners();
    });
  }

  List<String> get names => users.map((e) => e.name as String).toList();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

}
