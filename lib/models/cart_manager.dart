import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loja_virtual/models/cart_product.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/services/cepaberto_service.dart';
import 'package:loja_virtual/models/address.dart';

class CartManager extends ChangeNotifier {

  List<CartProduct> items = [];

  Users? user;
  Address? address;


  num productsPrice = 0.0;
  num? deliveryPrice;

  num get totalPrice => productsPrice + (deliveryPrice ?? 0);

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void updateUser(UserManager userManager){
    user = userManager.appUser;
    productsPrice = 0.0;
    items.clear();
    removeAddress();

    if(user != null){
      _loadCartItems();
      _loadUserAddress();
    }
  }

  Future<void> _loadCartItems() async {
    final QuerySnapshot cartSnap = await user!.cartReference.get();
    items = cartSnap.docs.map(
            (d) => CartProduct.fromDocument(d)..addListener(_onItemUpdated)
    ).toList();
  }

  Future<void> _loadUserAddress() async {
    if(user!.address != null
        && await calculateDelivery(user!.address!.lat!, user!.address!.long!)){
      address = user!.address;
      notifyListeners();
    }
  }

  void addToCart(Product product){
    try {
      final e = items.firstWhere((p) => p.stackable(product));
      e.increment();
    } catch (e){
      final cartProduct = CartProduct.fromProduct(product);
      cartProduct.addListener(_onItemUpdated);
      items.add(cartProduct);
      user!.cartReference.add(cartProduct.toCartItemMap())
          .then((doc) => cartProduct.id = doc.id);
      _onItemUpdated();
    }
    notifyListeners();
  }

  void removeOfCart(CartProduct cartProduct){
    items.removeWhere((p) => p.id == cartProduct.id);
    user!.cartReference.doc(cartProduct.id).delete();
    cartProduct.removeListener(_onItemUpdated);
    notifyListeners();
  }

  void clear() {
    for(final cartProduct in items){
      user!.cartReference.doc(cartProduct.id).delete();
    }
    items.clear();
    notifyListeners();
  }

  void _onItemUpdated(){
    productsPrice = 0.0;

    for(int i = 0; i < items.length; i++){
      final cartProduct = items[i];

      if(cartProduct.quantity == 0){
        removeOfCart(cartProduct);
        i--;
        continue;
      }

      productsPrice += cartProduct.totalPrice;

      _updateCartProduct(cartProduct);
    }

    notifyListeners();
  }

  void _updateCartProduct(CartProduct cartProduct){
    if(cartProduct.id != null)
      user!.cartReference.doc(cartProduct.id)
          .update(cartProduct.toCartItemMap());
  }

  bool get isCartValid {
    for(final cartProduct in items){
      if(!cartProduct.hasStock) return false;
    }
    return true;
  }

  // ADDRESS
  bool get isAddressValid => address != null && deliveryPrice != null;


  Future<void> getAddress(String cep) async {
    loading = true;

    final cepAbertoService = CepAbertoService();

    try {

      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);

      if(cepAbertoAddress != null){
        address = Address(
            street: cepAbertoAddress.logradouro,
            district: cepAbertoAddress.bairro,
            zipCode: cepAbertoAddress.cep,
            city: cepAbertoAddress.cidade.nome,
            state: cepAbertoAddress.estado.sigla,
            lat: cepAbertoAddress.latitude,
            long: cepAbertoAddress.longitude
        );
      }
      loading = false;
    } catch (e){
      loading = false;
      return Future.error('CEP Inválido');
    }
  }

  Future<void> setAddress(Address address) async {
    loading = true;

    this.address = address;

    if(await calculateDelivery(address.lat!, address.long!)){
      user!.setAddress(address);
      loading = false;
    } else {
      loading = false;
      return Future.error('Endereço fora do raio de entrega :(');
    }

  }


  void removeAddress(){
    address = null;
    deliveryPrice = null;
    notifyListeners();
  }


  Future<bool> calculateDelivery(double lat, double long) async {
    final DocumentSnapshot doc = await firestore.doc('aux/delivery').get();

    final latStore = doc['lat'] as double;
    final longStore = doc['long'] as double;

    final base = doc['base'] as num;
    final km = doc['km'] as num;
    final maxkm = doc['maxkm'] as num;

    double dis =
    await Geolocator().distanceBetween(latStore, longStore, lat, long);

    dis /= 1000.0;

    if(dis > maxkm){
      return false;
    }

    deliveryPrice = base + dis * km;
    return true;
  }

}
