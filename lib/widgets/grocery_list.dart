import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries',
        ),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(groceryItems[index].name),
            //indicatore per la categoria: quadrato con un colore della categoria
            leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[index].category.color,
            ),
            //quantità
            trailing: Text(groceryItems[index].quantity.toString()),
          );
        },
      ),
    );
  }
}
