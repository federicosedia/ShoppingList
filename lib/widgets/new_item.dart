import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

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

//in questa funzione attivo la validazione
//quindi il metodo save non può essere eseguito prima del build e che quindi form è stato chiamato
//perchè può essere eseguito solo dall'elevatebutton generato dal metodo build
//il validate dietro le quinte chiamata tutti i formfield ed esegue i validate
//ed eseguira
//il metodo save attiva una funzione speciale che si trova nel textformfield
//la funzione è onsaved
//metto tutto dentro un if la validazione, cosi se supera la validazione
//salvo la configurazione
  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
                      onPressed: () {
                        //metodo reset per reseattare
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Rest')),
                  //inviare il modulo
                  ElevatedButton(
                      onPressed: _saveItem, child: const Text('Invia')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
