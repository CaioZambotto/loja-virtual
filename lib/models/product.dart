import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/item_size.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Product extends ChangeNotifier {

  Product({this.id, this.name, this.description, this.images, this.sizes,
    this.deleted = false}){
    images = images ?? [];
    sizes = sizes ?? [];
  }

  Product.fromDocument(DocumentSnapshot document){

    id = document.id;
    name = document.get('name') as String;
    description = document.get('description') as String;
    images = List<String>.from(document['images'] as List<dynamic>);
    deleted = (document['deleted'] ?? false) as bool;

    try{
      sizes = (document.get('sizes') as List<dynamic> ).map(
              (s) => ItemSize.fromMap(s as Map<String, dynamic>)).toList();
    }catch(e){
      sizes = ([]).map(
              (s) => ItemSize.fromMap(s as Map<String, dynamic>)).toList();
    }

  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('products/$id');
  Reference get storageRef => storage.ref().child('products').child(id as String);


  String? id;
  String? name;
  String? description;
  List<String>? images;
  List<ItemSize>? sizes;
  bool? isButtonActive = false;
  List<dynamic>? newImages;
  bool? deleted;


  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  ItemSize? _selectedSize;

  ItemSize get selectedSize =>
      _selectedSize ?? ItemSize();


  set selectedSize(ItemSize value){
    _selectedSize = value;
    notifyListeners();
  }

  int get totalStock {
    int stock = 0;
    for(final size in sizes!){
      stock += size.stock!.toInt();
    }
    return stock;
  }

  bool get hasStock {
    return totalStock > 0 && !deleted!;
  }

  num get basePrice {
    num lowest = double.infinity;
    for(final size in sizes!){
      if(size.price! < lowest)
        lowest = size.price!;
    }
    return lowest;
  }

  ItemSize? findSize(String name){
    try {
      return sizes!.firstWhere((s) => s.name == name);
    } catch (e){
      return null;
    }
  }

  List<Map<String, dynamic>> exportSizeList(){
    return sizes!.map((size) => size.toMap()).toList();
  }

  Future<void> save() async {
    loading = true;
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'sizes': exportSizeList(),
      'deleted': deleted
    };

    if(id == null){
      final doc = await firestore.collection('products').add(data);
      id = doc.id;
    } else {
      await firestoreRef.update(data);
    }

    final List<String> updateImages = [];

    for(final newImage in newImages!){
      //if(images!.contains(newImage)){
      if(!images!.contains(newImage) && newImages!.contains('firebase')){
        updateImages.add(newImage as String);
      } else {
        final UploadTask task = storageRef.child(Uuid().v1()).putFile(newImage as File);
        final TaskSnapshot snapshot = await task;
        final String url = await snapshot.ref.getDownloadURL() as String;
        updateImages.add(url);
      }
    }

    for(final image in images!){
      if(!newImages!.contains(image)){
        try {
          final ref = await storage.refFromURL(image);
          await ref.delete();
        } catch (e){
          debugPrint('Falha ao deletar $image');
        }
      }
    }

    await firestoreRef.update({'images': updateImages});

    images = updateImages;

    loading = false;
  }

  void delete(){
    firestoreRef.update({'deleted': true});
  }

  Product clone(){
    return Product(
      id: id,
      name: name,
      description: description,
      images: List.from(images as List<dynamic>),
      sizes: sizes!.map((size) => size.clone()).toList(),
      deleted: deleted,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, images: $images, sizes: $sizes, newImages: $newImages}';
  }

}
