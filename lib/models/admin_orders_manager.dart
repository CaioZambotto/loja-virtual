import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/models/user.dart';

class AdminOrdersManager extends ChangeNotifier {

  final List<Orders> _orders = [];

  Users? userFilter;
  List<Status> statusFilter = [Status.preparing];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  void updateAdmin({bool? adminEnabled}){
    _orders.clear();

    _subscription?.cancel();
    if(adminEnabled!){
      _listenToOrders();
    }
  }

  List<Orders> get filteredOrders {
    List<Orders> output = _orders.reversed.toList();

    if(userFilter != null){
      output = output.where((o) => o.userId == userFilter!.id).toList();
    }

    return output.where((o) => statusFilter.contains(o.status)).toList();
  }

  void _listenToOrders(){
    _subscription = firestore.collection('orders').snapshots().listen(
            (event) {
              for(final change in event.docChanges){
                switch(change.type){
                  case DocumentChangeType.added:
                    _orders.add(
                        Orders.fromDocument(change.doc)
                    );
                    break;
                  case DocumentChangeType.modified:
                    final modOrder = _orders.firstWhere(
                            (o) => o.orderId == change.doc.id);
                    modOrder.updateFromDocument(change.doc);
                    break;
                  case DocumentChangeType.removed:
                    debugPrint('Deu problema sério!!!');
                    break;
                }
          }
          notifyListeners();
        });
  }

  void setUserFilter(Users? user){
    userFilter = user;
    notifyListeners();
  }

  void setStatusFilter({Status? status, bool? enabled}){
    if(enabled!){
      statusFilter.add(status!);
    } else {
      statusFilter.remove(status);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

}
