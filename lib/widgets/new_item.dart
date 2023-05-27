import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
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
                //restituiamo l'errore
                validator: (value) {
                  return 'Demo...';
                },
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
                      initialValue: '1',
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  //pulsante a discesa per scegliere una categoria
                  //anche qui come sopra devo vincolarlo orizzontalmente con expandend
                  Expanded(
                    child: DropdownButtonFormField(
                      //lista di categorie ma le categorie essendo una mappa
                      //verrà richiamato con entries per convertirlo
                      //è una proprietà che fornisce un iterabile che contiene le mappe chiave valore
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            //nel menù a tendina vedrò tutti i valori associati
                            //quindi colore e titolo
                            value: category.value,
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
                      onChanged: (value) {},
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
