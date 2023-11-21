import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/helpers/firebase_errors.dart';

class UserManager extends ChangeNotifier {

  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Users? appUser;

  bool loading = false;

  bool get isLoggedIn => appUser != null;

  Future<void> signIn({required Users user, required Function onFail, required Function onSuccess}) async {
    setLoading(true);
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);

      await _loadCurrentUser(user: user);
      //this.appUser = user;

      await Future.delayed(Duration(seconds: 2));
      onSuccess();

    } on FirebaseAuthException catch (e) {
      onFail(getErrorString(e.code));
    }
    setLoading(false);
  }

  Future<void> signUp({required Users user,required Function onFail,required Function onSuccess}) async {
    loading = true;
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
          email: user.email!, password: user.password!);

      //    this.appUser = user;
      await _loadCurrentUser();
      user.id = result.user!.uid;

      await user.saveData();

      onSuccess();
    } on PlatformException catch (e){
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  void signOut(){
    auth.signOut();
    appUser = null;
    notifyListeners();
  }

  void setLoading(bool value){
    loading = value;
    notifyListeners();
  }

  Future<void> _loadCurrentUser({Users? user}) async {
    //final Usuario? currentUser = user ?? auth.currentUser;
    auth.authStateChanges().listen((User? user) async {
    //if (currentUser != null) {
      if (user != null) {
        final docUser = await firestore.collection('users').doc(user.uid).get();
        appUser = Users.fromDocument(docUser);

        final docAdmin = await firestore.collection('admins').doc(appUser!.id).get();
        if(docAdmin.exists){
          appUser!.admin = true;
        }

        notifyListeners();
      }
    });
  }

  bool get adminEnabled => appUser != null && appUser!.admin;
}
