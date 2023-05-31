import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  //mi creo una nuova variabile nella quale salverò la lista di prodotti
  //dato che non può essere null utilizzo "late" che assicura che dopo verrà valorizzato prima che verrà utilizzato
  late Future<List<GroceryItem>> _loadedItems;
  //poichè siamo in una classe di state aggiungo initstate
  //che consente di fare alcune operazioni di inizializzazione
  //quindi possiamo inviare la richiesta
  //però se nel loaditems facciamo il print del body vedremo in console
  @override
  void initState() {
    super.initState();
    //uso la nuova variabile per prendermi i prodotti ricevuti dal get e salvarmeli
    _loadedItems = _loadItems();
  }

  //sposto tutta la parte di estrazione in loaditems
  //posso cambiare il tipo da void a list<GroceryItem> però dato che stiamo usando async otteniamo un errore
  //perchè con async ritorniamo un future. Quindi sarà di tipo future
  //con le modifiche apportate abbiamo ottenuto una loaditems più snella
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'shop-list-fe-default-rtdb.firebaseio.com', 'shopping-list.json');

//throw Excpetion blocca l'esecuzione e restituisce l'errore incontrato
//con try e catch. In try aggiungiamo il codice che può fallire
//catch aggiunto dopo le parentesi graffe cattura l'errore che può essere ricevuto
//quindi appena si riceve un errore viene catchato like throw expection

    final response = await http.get(url);
    //gli errori di solito sono >400 quindi posso prevedere una schermata diversa
//piuttosto che bloccare l'utente quando riceve un errore
//quindi qui aggiorno il messaggio in error
//nell'if mostro questa schermata con questo messaggio se error != null
    if (response.statusCode >= 400) {
      throw Exception("Please try again later.");
    }
    //dato che possiamo vedere gli oggetti ma sottoforma di json
    //converto da json a dart in un elenco di item grocery
    //mappa di string, map perchè la chiave è la stringa del nodo
    //il valore è la mappa degli oggetti
    //la mappa, valore della prima mappa, ha string e dynamic
    //string data dalla chiave di categoria name e quantity
    //dynamic invece perchè il valore cambia tra quantità stringa e categoria

//aggiungo questo if perchè se non ho item nel backend allora mi trovo nella situazione in cui
//non posso andare avanti e rimango bloccato. questo perchè listdata è di tipo map
//però non avendo item ottengo null. Nell'if pongo response.body=='null' e non null perchè firebase
//restituisce la stringa null
//inoltre restituisco lista vuota perchè ci si aspetta una lista
//questo perchè il caricamento degli item dovrebbe restituire un elenco
    if (response.body == 'null') {
      //posso rimuovere il setstate sempre grazie al futurebuilder
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
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
//eliminiamo set state e ritorniamo i nostri loaditem
//tolgo il metodo try-catch perchè con il futurebuilder possiamo gestire gli errori in modo diverso

    return loadedItem;
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

  void _removeditem(GroceryItem item) async {
    //con index salvo l'id dell'item cosi da poterlo salvare nuovamente in caso di errore nella cancellazione
    final index = _groceryItems.indexOf(item);
    //con la rimozione il delete punta ad un singolo item del db
    //quindi aggiungo nel secondo pezzo di stringa /<id_item>
    //non ho bisogno di aggiungere async e await come quando aggiungiamo un item
    //se viene fuori un errore potrebbe cancellarsi solo localmente e non anche a db
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('shop-list-fe-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
//se qualcosa va storto aggiungo di nuovo l'item
//per aggiungerlo con lo stesso id utilizzo insert
    if (response.statusCode >= 400) {
      setState(
        () {
          _groceryItems.insert(index, item);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      //costruisco un nuovo widget che mi permette di ottenere dei dati quando risolve un future
      //quindi possiamo utilizzarlo qui invece di content
      //ha bisogno di due parametri chiave: future ovvero il future a cui dovrà attendere e ascoltare
      //e builder che vuole un funzione che viene eseguita ogni volta che il future produce dati
      body: FutureBuilder(
        //voglio un future che produca una risposta dopo che arrivano i dati dalla get http
        //risultato della chiamata alla funzione loaditems
        //però non è consigliabile farlo in questo modo
        //perchè se si chiama loaditems per ottenere il future che viene passato come valore al costruttore
        //viene eseguito ogni volta che il build viene eseguito, quindi quando cambia lo stato
        //quindi converebbe utilizzare initstate e quindi la nuova variabile che prende i valori e li pone uguale a quelli caricati

        future: _loadedItems,
        //context= contesto passato da flutter
        //snapshot= da accesso allo stato attuale del future e ai dati che potrebbero essere prodotti
        builder: (context, snapshot) {
          //facciamo un return in base ai diversi stati del future
          //per farlo uso snapshot. Con connectionstate posso usare l'enum
          //come primo utilizzo waiting quindi se siamo in attesa restituiamo lo spinner di caricamento

          if (snapshot.connectionState == ConnectionState.waiting) {
            //quindi qui aggiungo a schermo che se isloading =true a schermo vedrò quella immagine
            const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              //con snapshot ho accesso alla proprietà error che mi da accesso all'oggetto exception
              //quindi chiamo anche il tostring per avere la stringa
              child: Text(snapshot.error.toString()),
            );
          }
          //voglio gestire il caso in cui non ci sia attessa e non ho errori
          //quindi voglio avere l'elenco dei dati
          //se non ho dati allora restituisco
          if (snapshot.data != null) {
            return const Center(
              child: Text('No items added yet'),
            );
          }
          //se ho i dati invece il listview:
          else {
            return ListView.builder(
              //cambio il groceryitem con snapshot.data!
              //perchè l'elenco è disponibile anche con l'oggetto snapshot
              itemCount: snapshot.data!.length as int,
              itemBuilder: (BuildContext context, int index) =>
                  //avvolgendo il widget listitle con dismissibile
                  //posso scorrere gli elementi per eliminarli
                  //per farlo aggiungo anche la chiave e utilizzo la valuekey
                  //con la valuekey utilizzo come indiceunivoco l'id dell'oggetto
                  //inoltre utilizzo ondismissed per permettere tramite lo scorrimento
                  //di far avviare un metodo che ho creato
                  //esso andrà a rimuovere l'oggetto che si sta scorrendo
                  Dismissible(
                key: ValueKey(snapshot.data![index].id),
                onDismissed: (direction) {
                  _removeditem(snapshot.data![index]);
                },
                child: ListTile(
                  title: Text(snapshot.data![index].name),
                  //indicatore per la categoria: quadrato con un colore della categoria
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: snapshot.data![index].category.color,
                  ),
                  //quantità
                  trailing: Text(snapshot.data![index].quantity.toString()),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
