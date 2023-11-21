import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loja_virtual/common/custom_icon_button.dart';
import 'package:loja_virtual/models/cart_manager.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/models/address.dart';

class CepInputField extends StatefulWidget {

  const CepInputField(this.address);

  final Address address;

  @override
  State<CepInputField> createState() => _CepInputFieldState();
}

class _CepInputFieldState extends State<CepInputField> {
  final TextEditingController cepController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();
    final primaryColor = Theme.of(context).primaryColor;

    if(widget.address.zipCode == null)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            enabled: !cartManager.loading,
            controller: cepController,
            decoration: const InputDecoration(
                isDense: true,
                labelText: 'CEP',
                hintText: '12.345-678'
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CepInputFormatter(),
            ],
            keyboardType: TextInputType.number,
            validator: (cep){
              if(cep!.isEmpty)
                return 'Campo obrigatório';
              else if(cep.length != 10)
                return 'CEP Inválido';
              return null;
            },
          ),
          if(cartManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          ElevatedButton(
            onPressed: cartManager.loading ? null : () async {
              if(Form.of(context)!.validate()){
                try {
                  await context.read<CartManager>().getAddress(cepController.text);
                } catch (e){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('$e'),
                        duration: const Duration(seconds: 3),
                      )
                  );
                }
              }
            },
            child: const Text('Buscar CEP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // Background color
              disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
            ),
          ),
        ],
      );
    else
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'CEP: ${widget.address.zipCode}',
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
            CustomIconButton(
              iconData: Icons.edit,
              color: primaryColor,
              size: 20,
              onTap: (){
                context.read<CartManager>().removeAddress();
              },
            ),
          ],
        ),
      );
  }
}
