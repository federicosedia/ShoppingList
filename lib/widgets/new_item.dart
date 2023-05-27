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
                //restituiamo l'errore e se passa il controllo allora viene inviato correttamente
                //trim server per indicare se il valore è stato tagliato "rimuove gli spazi bianchi all'inizio e alla fine"
                //quindi se qualcosa è stato tagliato restituisco errore
                //l'ultima condizione invece per dire che la lunghezza non deve essere superiore a 50 dopo aver tolto gli spazi vuoti
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 character';
                  }
                  return null;
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
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                //asse orizzontale
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //reimpostare il modulo
                  TextButton(onPressed: () {}, child: const Text('Rest')),
                  //inviare il modulo
                  ElevatedButton(onPressed: () {}, child: const Text('Invia')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
