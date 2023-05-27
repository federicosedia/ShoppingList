import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
//context non disponibile in stateless quindi aggiungo come argomento
  void _addItem() {
    //push -> la mia nuova screen va sopra quella precedente
    //materialpage route prende la funzioone builder dove ottinaimo per ogni contesto
    //la schermata da buildare
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Groceries',
        ),
        actions: [
          IconButton(
              onPressed: () {
                _addItem();
              },
              icon: const Icon(Icons.add))
        ],
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
