import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  //qui salverò tutti gli oggetti che andrò ad aggiungere tramite il form
  //ed essendo una lista di oggetti di quel tipo salvo in questo modo la proprietà
  final List<GroceryItem> _groceryItems = [];
//context non disponibile in stateless quindi aggiungo come argomento
  void _addItem() async {
    //push -> la mia nuova screen va sopra quella precedente
    //materialpage route prende la funzioone builder dove ottinaimo per ogni contesto
    //la schermata da buildare
    //dato che stiamo passando dei dati dalla schermata b alla schermata a
    //tramite questo metodo verranno aggiunti ma solo una volta che verranno passati
    //quindi dovrò utilizzare async e await
    //push produce un futuro che contiene i dati che possono essere tornati tramite la nuova schermata
    //può essere nullo perchè possiamo tornare indietro
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
//se è nullo allora ritorno null
    if (newItem == null) {
      return;
    }
//setstate per aggiornare lo stato quando viene aggiunto il nuovo elemento
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeditem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet'),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (BuildContext context, int index) =>
            //avvolgendo il widget listitle con dismissibile
            //posso scorrere gli elementi per eliminarli
            //per farlo aggiungo anche la chiave e utilizzo la valuekey
            //con la valuekey utilizzo come indiceunivoco l'id dell'oggetto
            //inoltre utilizzo ondismissed per permettere tramite lo scorrimento
            //di far avviare un metodo che ho creato
            //esso andrà a rimuovere l'oggetto che si sta scorrendo
            Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeditem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            //indicatore per la categoria: quadrato con un colore della categoria
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            //quantità
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
      body: content,
    );
  }
}
