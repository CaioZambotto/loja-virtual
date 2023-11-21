import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/screens/product_consult/components/size_widget.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {

  const ProductScreen(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name.toString()),
          centerTitle: true,
          actions: [
            Consumer<UserManager>(
              builder: (_, userManager, __){
                if(userManager.adminEnabled && !product.deleted!){
                  return IconButton(
                    onPressed: (){
                      Navigator.of(context).pushReplacementNamed(
                        '/edit_product',
                        arguments: product,
                      );
                    },
                    icon: Icon(Icons.edit),
                  );
                } else {
                  return Container();
                }
              }
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Carousel(
                images: product.images!.map((url){
                  return NetworkImage(url.toString());
                }).toList(),
                dotSize: 4,
                dotSpacing: 15,
                dotBgColor: Colors.transparent,
                dotColor: primaryColor,
                autoplay: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    product.name.toString(),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'A partir de',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ ${product.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  Text(
                    product.description.toString(),
                    style: const TextStyle(
                        fontSize: 16
                    ),
                  ),
                  if(product.deleted!)
                    const Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Produto Indisponivel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else
                    ...[
                      const Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          'Tamanhos',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.sizes!.map((s){
                          return SizeWidget(s);
                        }).toList(),
                      ),
                    ],
                  const SizedBox(height: 20,),
                  if(product.hasStock)
                    Consumer2<UserManager, Product>(
                      builder: (_, userManager, product, __){
                        return SizedBox(
                          height: 44,
                            child: ElevatedButton(
                              onPressed: product.isButtonActive != false
                                  ? () {
                                if (userManager.isLoggedIn) {
                                  context.read<CartManager>().addToCart(product);
                                  Navigator.of(context).pushNamed('/cart');
                                } else {
                                  Navigator.of(context).pushNamed('/login');
                                }
                              } : null,
                              child: Text(
                                userManager.isLoggedIn
                                    ? 'Adicionar ao Carrinho'
                                    : 'Entre para Comprar',
                                  style: const TextStyle(
                                  fontSize: 18
                              ),
                            ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.teal, // Background color
                                disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                              ),
                            ),
                        );
                      },
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}