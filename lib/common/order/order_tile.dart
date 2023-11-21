import 'package:flutter/material.dart';
import 'package:loja_virtual/common/order/cancel_order_dialog.dart';
import 'package:loja_virtual/common/order/export_address_dialog.dart';
import 'package:loja_virtual/models/order.dart';
import 'package:loja_virtual/common/order/order_product_tile.dart';

class OrderTile extends StatelessWidget {

  const OrderTile(this.order, {this.showControls = false});

  final Orders order;
  final bool showControls;


  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.formattedId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'R\$ ${order.price!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              order.statusText,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: order.status == Status.canceled ?
                  Colors.red : primaryColor,
                  fontSize: 14
              ),
            )
          ],
        ),
        children: <Widget>[
          Column(
            children: order.items!.map((e){
              return OrderProductTile(e);
            }).toList(),
          ),
          if(showControls && order.status != Status.canceled)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  SizedBox(width: 4,),
                  TextButton(
                    onPressed: (){
                      showDialog(context: context,
                          builder: (_) => CancelOrderDialog(order)
                      );
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(width: 6,),
                  TextButton(
                    onPressed: order.back,
                    child: Text(
                      'Recuar',
                      style: TextStyle(
                        fontSize: 14,
                        color: order.status!.index == 1 ?
                        Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 6,),
                  TextButton(
                    onPressed: order.advance,
                    child: Text(
                      'Avançar',
                      style: TextStyle(
                        fontSize: 14,
                        color: order.status!.index == 3 ?
                        Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 6,),
                  TextButton(
                    onPressed: (){
                      showDialog(context: context,
                          builder: (_) => ExportAddressDialog(order.address!)
                      );
                    },
                    child: const Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal,
                      ),),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}