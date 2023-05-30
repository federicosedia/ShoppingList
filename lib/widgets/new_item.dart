import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

//per poter salvare nel database di firebase i dati che passiamo
//altirmenti verrebbero salvati solo localmente
//verrà fatto tramite una richiesta http
//con "as" diciamo che tutti i pacchetti verranno raggruppati in un oggetto con nome http
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  //creo una nuova globalkey usando il costruttore globalkey
  //crea un oggetto di tipo globalkey che può essere utilizzato nel form
  //la globalkey è generica però posso dire a flutter a chi è collegata
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  //voglio aggiungere una nuova proprietà per non permettere di generare una nuova richiesta dopo che se ne è fatta una
  // e si sta attendendo di tornare nella pagina di riepilogo
  //questo perchè provando a fare una richiesta ci vorranno dei secondi prima che venga elaborata
  var _isSending = false;

//in questa funzione attivo la validazione
//quindi il metodo save non può essere eseguito prima del build e che quindi form è stato chiamato
//perchè può essere eseguito solo dall'elevatebutton generato dal metodo build
//il validate dietro le quinte chiamata tutti i formfield ed esegue i validate
//ed eseguira
//il metodo save attiva una funzione speciale che si trova nel textformfield
//la funzione è onsaved
//metto tutto dentro un if la validazione, cosi se supera la validazione
//salvo la configurazione
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //qui voglio impostare il valore issending=true ovvero dopo aver salvato il nuovo item
      //quindi dopo aver salvato l'oggetto chiamo il setstate
      setState(() {
        if (_isSending = false) {
          _isSending = true;
        }
      });
      //creiamo una url e la salviamo nella variabile url
      //possiamo utilizzare la classe uri che accetta come costruttore https
      //che crea una url che punta ad un backend https
      //la prima parte dell'url può essere presa dal db di firebase "prima della virgola"
      //la seconda parte viene decisa da noi ma deve essere aggiunto .json che è richiesto da firebase
      //appena invieremo dati in firebase verrà creato un nodo con il secondo nome deciso da noi
      final url = Uri.https(
          'shopping-list-app-3fce2-default-rtdb.firebaseio.com',
          'shopping-list.json');
      //get per ottenere dati presenti nel db
      //post per inserire dati
      //delete per cancellari dati
      //patch aggiorna parte dei dati
      //put sovrascrive dati
      //dato che dobbiamo inviare dati utilizziamo post
      //post ha bisogno di una url
      //inoltre accetta "header" una mappa di intestazioni ovvero metadati che possono essere aggiunti alla richiesta in uscita
      //body per allegare dati alla richiesta in uscita
      //per la mappa di header ho le chiavi che sono gli identificatori e i valori sono impostazioni per quegli header
      //questo header aiuterà a firebase a capire come sono formattati i dati
      //con body passo i dati e in teoria tutto il widget groceryitem che già facevo risalire con pop
      //cambierà solo la formatazzione perchè i dati dovranno essere passati in formato json
      //abbiamo però l'oggetto json e il metodo encode che ci aiutano nella formattazione
      //utilizzeremo una mappa per convertire i dati
      //per formattarli prendo i dati che passavo nel groceryitem e avvolgo le chiavi tra virgolette
      //firebase genera automaticamente l'id quindi non sarà necessario passarlo
      //l'invio dei dati non è immediato perchè bisogna creare la richiesta
      //essere inviata al backend e il backend poi deve gestirla
      //per essere sicuri che la richiesta è stata analizzata con successo
      //sfruttiamo il metodo post che fa un return della future<response>
      //quindi aggiungiamo il metodo then oppure async await(di fronte al metodo che produce il futuro)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );
      //qui avremo accesso alla risposta, il quale ha un paio di proprietà
      //ad esempio status code che è un int 200/201 allora ha funzionato mentre 400/404/500 non ha funzionato
      //response.statusCode.
      //quindi provo a stampare nella console lo status e il body
      //dopodichè chiamo il metodo pop. Però per evitare problemi sul contesto che potrebbe ancora e
      //perchè non potrei utilizzare il context dopo async perchè non sappiamo se è lo stesso
//      print(response.body);
//    print(response.statusCode);
      //quindi aggiungo questo if per controllare se è a schermo oppure no
      if (!context.mounted) {
        return;
      }

      final Map<String, dynamic> resData = json.decode(response.body);
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );

      //posso passare i dati da questo screen allo screen della lista di grocery
      //per farlo utilizzo il navigator.pop (devo uscire da questo screen per andare nel prossimo)
      //si naviga vs la schermata A rimuovendo la schermata B "B= nuovo oggetto" "A= lista oggetti"
      //con pop inoltre possiamo passare alcuni dati

      //commento il navigator perchè voglio passare i dati solo a firebase
      //Navigator.of(context).pop(
      ///GroceryItem(
      //per id utilizzo il datastamp
      //id: DateTime.now().toString(),
      //_enteredName salvato con save
      //name: _enteredName,
      //quantity: _enteredQuantity,
      //category: _selectedCategory,
      //),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a new Item',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        //il fomr è una combinazione di campi di input
        //ha incorparato anche dei controlli come la validazione dei dati inseriti
        child: Form(
          //per dire a flutter che devono essere eseguiti tutti i controlli di validazione
          //l'accesso al form avviene tramite una chiave
          //non viene quindi utilizzata solo per identificare i widget in un elenco
          //la key però verrà creata come proprietà
          //la global ci permette di accedere facilmente ai widget dove è collegata
          //e se viene settato un nuovo stato non viene ricostruito
          //è lo stato interno che dirà a flutter se mostrare alcuni errori di validazione oppure no
          //la chiave globale serve sopratutto per i moduli
          key: _formKey,
          child: Column(
            children: [
              //con form utilizzo texformfiled a differenza di texfield
              //inoltre ci sono molti bottoni che possono essere utilizzati con form
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                //validator permette di prendere in input una string e inoltre restituisce una stringa
                //quindi passando una funzione possiamo passare un controllo e se il controllo fallisce
                //restituiamo l'errore e se passa il controllo allora viene inviato correttamente
                //trim server per indicare se il valore è stato tagliato "rimuove gli spazi bianchi all'inizio e alla fine"
                //quindi se qualcosa è stato tagliato restituisco errore
                //l'ultima condizione invece per dire che la lunghezza non deve essere superiore a 50 dopo aver tolto gli spazi vuoti
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 character';
                  }
                  return null;
                },
                //"value" = valore passato in saveitem
                //quindi lo pongo uguale a la nuova variabile dove voglio salvare la stringa

                onSaved: (value) {
                  //non necessario perchè ho la validazioni
                  // if (value == null) {
                  // return;
                  //}

                  _enteredName = value!;
                },
                //numero linee massimo
                maxLines: 3,
                minLines: 1,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //quantità. Non essendo vincolato orizzontalmente
                  //devo vincolarlo io con expandend altrimenti ricevo un errore
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text(
                          'Quantity',
                        ),
                      ),
                      //valore iniziale "stringa"
                      //quindi prendo il valore iniziale e lo cambio in stringa anche se voglio un numero
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      //tryParse da null quando prova a convertira una stringa non numerica
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        //parse lancia un errore se non riesce a convertire in numero
                        //mentre try restituisce null
                        //value sarà sempre una string però io voglio un numero quindi chiamo parse
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  //pulsante a discesa per scegliere una categoria
                  //anche qui come sopra devo vincolarlo orizzontalmente con expandend
                  Expanded(
                    //non è necessario (rispetto quanto scritto in onchange) prevedere anche il onsave
                    child: DropdownButtonFormField(
                      //non supporta initialvalue ma solo value
                      value: _selectedCategory,
                      //lista di categorie ma le categorie essendo una mappa
                      //verrà richiamato con entries per convertirlo
                      //è una proprietà che fornisce un iterabile che contiene le mappe chiave valore
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            //nel menù a tendina vedrò tutti i valori associati
                            //quindi colore e titolo
                            value: _selectedCategory,
                            child: Row(
                              children: [
                                //container per box con colore della categoria
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                //testo da mostrare ovvero nome della categoria
                                //qui abbiamo sia key che value perchè con entries abbiamo l'iterabile della mappa
                                //quello che interessa a noi però è il valore della chiave e non la chiave
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        //qui dobbiamo chiamare anche il setstate a differenza degli altri onchanged
                        //questo perchè la categoria selezionata viene utilizzata per impostare il valore visibile
                        //quindi deve essere sincronizzato con quanto scelto nel menù a tendina
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                //asse orizzontale
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //reimpostare il modulo
                  TextButton(
                      //dopo che salvo l'oggetto e sono nella schermata e prima quindi di essere catapultato nella maschera di riepilogo
                      //voglio rendere la funzione onpressed nulla cosi da non permettere all'utente di fare un secondo inserimento
                      onPressed: _isSending
                          ? null
                          : () {
                              //metodo reset per reseattare
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Rest')),
                  //inviare il modulo
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? SizedBox(
                              height: 8,
                              width: 8,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Invia')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
