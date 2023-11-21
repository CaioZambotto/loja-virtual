import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/models/section_item.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:loja_virtual/models/product_manager.dart';

class ItemTile extends StatelessWidget {

  ItemTile({required this.item, this.valueKey, this.height});

  final SectionItem item;
  ValueKey<dynamic>? valueKey;
  double? height;

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>();
    return GestureDetector(
      onTap: () {
        if (item.product != null) {
          final product = context.read<ProductManager>()
              .findProductById(item.product.toString());
          if (product != null) {
            Navigator.of(context).pushNamed('/product', arguments: product);
          }
        }
      },
      onLongPress: homeManager.editing ? (){
        showDialog(
            context: context,
            builder: (_){

              final product = context.read<ProductManager>()
                  .findProductById(item.product as String);

              return AlertDialog(
                title: const Text('Editar Item'),
                content: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: product != null
                        ? Image.network(product?.images?.first ?? "") : SizedBox(),
                    title: Text(product?.name as String ?? ""),
                    subtitle: product != null
                        ? Text('R\$ ${product?.basePrice.toStringAsFixed(2)}') : Text(''),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: (){
                      context.read<Section>().removeItem(item);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Excluir'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if(product != null){
                        item.product = null;
                      } else {
                        final Product product = await Navigator.of(context)
                            .pushNamed('/select_product') as Product;
                        item.product = product.id ?? "";
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(
                        product != null
                            ? 'Desvincular'
                            : 'Vincular'
                    ),
                  ),
                ],
              );
            }
        );
      } : null,
      child: item.image is String
          ? FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: item.image as String,
        fit: BoxFit.cover,
      )
          : Image.file(item.image as File, fit: BoxFit.cover,),
    );
  }
}