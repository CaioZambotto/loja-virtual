import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/user_manager.dart';
import 'package:loja_virtual/screens/home/components/add_section_widget.dart';
import 'package:loja_virtual/screens/home/components/section_list.dart';
import 'package:provider/provider.dart';
import 'package:loja_virtual/screens/home/components/section_staggered.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: const [
                      Color.fromARGB(255, 65, 150, 150),
                      Color.fromARGB(255, 150, 198, 204),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                )
            ),
          ),
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text('Loja do Caio'),
                  centerTitle: true,
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pushNamed('/cart'),
                  ),
                  Consumer2<UserManager, HomeManager>(
                    builder: (_, userManager, homeManager, __){
                      if(userManager.adminEnabled && !homeManager.loading) {
                        if(homeManager.editing){
                          return PopupMenuButton(
                            onSelected: (e){
                              if(e == 'Salvar'){
                                homeManager.saveEditing();
                              } else {
                                homeManager.discardEditing();
                              }
                            },
                            itemBuilder: (_){
                              return ['Salvar', 'Descartar'].map((e){
                                return PopupMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList();
                            },
                          );
                        } else {
                          return IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: homeManager.enterEditing,
                          );
                        }
                      } else return Container();
                    },
                  ),
                ],
              ),
              Consumer<HomeManager>(
                builder: (_, homeManager, __){
                  if(homeManager.loading){
                    return SliverToBoxAdapter(
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  }

                  final List<Widget> children = homeManager.sections.map<Widget>(
                          (section) {
                            switch(section.type){
                              case 'List':
                                return SectionList(section);
                              case 'Staggered':
                                return SectionStaggered(section);
                              default:
                                return Container();
                            }
                        }
                  ).toList();
                  
                  if(homeManager.editing)
                    children.add(AddSectionWidget(homeManager));
                  
                  return SliverList(
                    delegate: SliverChildListDelegate(children),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}