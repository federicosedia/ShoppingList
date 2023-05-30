import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/data/categories.dart';
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
  //voglio riassegnare groceryitems
  List<GroceryItem> _groceryItems = [];
  String? error;
  //voglio aggiungere uno spinner prima che i dati vengono ricaricati quando runniamo l'app

  var isLoading = true;
  //poichè siamo in una classe di state aggiungo initstate
  //che consente di fare alcune operazioni di inizializzazione
  //quindi possiamo inviare la richiesta
  //però se nel loaditems facciamo il print del body vedremo in console
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  //sposto tutta la parte di estrazione in loaditems
  void _loadItems() async {
    final url = Uri.https('shopping-list-app-3fce2-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
//gli errori di solito sono >400 quindi posso prevedere una schermata diversa
//piuttosto che bloccare l'utente quando riceve un errore
//quindi qui aggiorno il messaggio in error
//nell'if mostro questa schermata con questo messaggio se error != null
    if (response.statusCode >= 400) {
      setState(() {
        error = 'Errore, si prega di riprovare più tardi';
      });
    }
    //dato che possiamo vedere gli oggetti ma sottoforma di json
    //converto da json a dart in un elenco di item grocery
    //mappa di string, map perchè la chiave è la stringa del nodo
    //il valore è la mappa degli oggetti
    //la mappa, valore della prima mappa, ha string e dynamic
    //string data dalla chiave di categoria name e quantity
    //dynamic invece perchè il valore cambia tra quantità stringa e categoria
    final Map<String, dynamic>? listData =
        json.decode(response.body) as Map<String, dynamic>?;
    //lista dove salverò gli oggetti che voglio ottenere
    //è una lista temporanea perche poi voglio sostituire l'elenco
    //che usiamo in _groceryItems nelle classi con questo elenco dopo aver passato gli elementi caricati

    final List<GroceryItem> loadedItem = [];
    for (final item in listData.entries) {
      //per ottenere la categoria dall'elenco delle categorie
      //voglio raggiungere la mappa delle categorie e tutte le voci
      //elenco di elementi in cui ogni elemento ha una proprietà key e una proprietà value
      //dato che si tratta di un elenco possiamo cercare il primo elemento che corrisponde ad una determinata condizione
      //firstwhere produce solo il primo elemento where tutti
      //quindi in pratica stiamo passando tutte le voci della mappa categories, dove le chiavi sono valori di enum e i valori sono oggetti di categorie
      //stiamo analizzando tutti questi elementi e per ogni elemento controllo se il valore, quindi Category, ha un titolo che è uguale
      // che è uguale al valore memorizzato sotto la chiave category di quell'elemento
      //i dati di questo elenco sono i nostri dati di risposta. Quindi l'elemento si riferisce ai dati di risposta

      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      //per salvare il nuovo oggetto risultante da quello che ci viene passato nel backend
      //chiamo il metodo add e dato che sto aggiungendo un groceryitem
      //specifico tutti i parametri
      //tramite questa formatazzione accediamo alla chiave con un nome all'interno di una mappa annidata
      loadedItem.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = loadedItem;
      //dato che siamo nel metodo loaditem qui voglio fare in modo che all'inzio venga mostrato
      //un'icona di caricamento anzichè la lista vuota "prima di ricevere col get le info dal db"
      //quindi isloading sarà uguale false dopo aver caricato gli elementi
      isLoading = false;
    });
  }

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
//voglio recuperare i dati tramite una get quindi prendendoli direttamente dal backend
//quindi rimuovo il navigator of context perchè non ricevo i dati tramite la chiusura
    //come gia fatto per il saveitem qui andrò a recuperare i dati quindi dopo essermi dichiarato l'url
    //mi dichiaro la response e la stampo a console
    //qui carico gli item tramite il metodo definito sopra
    //_loadItems();
    if (newItem == null) {
      return;
    }
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
    //quindi qui aggiungo a schermo che se isloading =true a schermo vedrò quella immagine
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

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
//se ricevo un'errore quindi mostrerò una schermata con l'errore
    if (error != null) {
      content = Center(
        child: Text(error!),
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
