import 'package:card_game_flutter/requests.dart';
import 'package:flutter/material.dart';

import 'cards.dart';

class CreateDeckWidget extends StatefulWidget {
  final Function(Cards) updateCard;

  const CreateDeckWidget({Key? key, required this.updateCard})
      : super(key: key);

  @override
  State<CreateDeckWidget> createState() => _CreateDeckWidgetState();
}

class _CreateDeckWidgetState extends State<CreateDeckWidget> {
  bool _loading = false;
  int _deckSize = 52;

  void onPressedCreated() async {
    setState(() {
      _loading = true;
    });

    Requests.createCards(_deckSize)
        .then((value) => widget.updateCard(value))
        .whenComplete(() => setState(() {
              _loading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    } else {
      return FractionallySizedBox(
        widthFactor: (MediaQuery.of(context).size.width < 980)
            ? 1
            : (MediaQuery.of(context).size.width / 2) /
                MediaQuery.of(context).size.width,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Deck de 32 cartes'),
                leading: Radio<int>(
                  value: 32,
                  groupValue: _deckSize,
                  onChanged: (int? value) {
                    setState(() {
                      _deckSize = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Deck de 52 cartes'),
                leading: Radio<int>(
                  value: 52,
                  groupValue: _deckSize,
                  onChanged: (int? value) {
                    setState(() {
                      _deckSize = value!;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text("Créer un jeu de carte"),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.lightGreen,
                      padding: const EdgeInsets.all(24),
                    ),
                    onPressed: onPressedCreated,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
