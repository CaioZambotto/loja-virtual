import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loja_virtual/models/home_manager.dart';
import 'package:loja_virtual/models/section.dart';
import 'package:loja_virtual/screens/home/components/add_tile_widget.dart';
import 'package:loja_virtual/screens/home/components/item_tile.dart';
import 'package:loja_virtual/screens/home/components/section_header.dart';
import 'package:provider/provider.dart';

class SectionStaggered extends StatelessWidget {

  const SectionStaggered(this.section);

  final Section section;

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>();

    return ChangeNotifierProvider.value(
      value: section,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(),
            Consumer<Section>(
              builder: (_, section, __){
                return
                  Container(
                    height: 500,
                    child: MasonryGridView.count(
                     padding: EdgeInsets.zero,
                     scrollDirection: Axis.horizontal,
                     crossAxisCount: 2,
                     mainAxisSpacing: 4,
                     crossAxisSpacing: 4,
                     shrinkWrap: true,
                     itemCount: homeManager.editing
                       ? section.items!.length + 1
                       : section.items!.length,
                    itemBuilder: (_, index){
                    if(index < section.items!.length)
                      return ItemTile(
                        height:( index % 3 + 1) * 30,
                        item: section.items![index], valueKey: ValueKey(section.items![index],));
                    else
                      return AddTileWidget();
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}