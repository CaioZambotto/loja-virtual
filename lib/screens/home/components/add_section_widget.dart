import 'package:flutter/material.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/section.dart';

class AddSectionWidget extends StatelessWidget {

  const AddSectionWidget(this.homeManager);

  final HomeManager homeManager;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextButton(
            onPressed: (){
              homeManager.addSection(Section(type: 'List'));
            },
            child: const Text('Adicionar Lista'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: (){
              homeManager.addSection(Section(type: 'Staggered'));
            },
            child: const Text('Adicionar Grade'),
          ),
        ),
      ],
    );
  }
}