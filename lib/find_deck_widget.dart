import 'package:card_game_flutter/requests.dart';
import 'package:flutter/material.dart';

import 'cards.dart';

class FindDeckWidget extends StatefulWidget {
  final Function(Cards) updateCard;

  const FindDeckWidget({Key? key, required this.updateCard}) : super(key: key);

  @override
  State<FindDeckWidget> createState() => _FindDeckWidgetState();
}

class _FindDeckWidgetState extends State<FindDeckWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardIdController = TextEditingController();
  bool _processing = false;
  String? _message;

  void onPressedFind() async {
    setState(() {
      _message = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _processing = true;
      });
      Requests.getCards(_cardIdController.value.text)
          .then((cards) => widget.updateCard(cards))
          .catchError((error) => setState(() {
                _message = error.message;
              }))
          .whenComplete(() => setState(() {
                _processing = false;
              }));
    }
  }

  String? validatorTextField(value) {
    if (value == null || value.isEmpty) {
      return "Merci de taper l'identifiant du deck";
    }
    return null;
  }

  Widget renderButton() {
    if (_processing) {
      return const CircularProgressIndicator();
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          child: const Text("Récupérer un jeu de carte"),
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(24),
          ),
          onPressed: onPressedFind,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: FractionallySizedBox(
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
              if (_message != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  width: double.infinity,
                  child: Text(
                    _message!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(
                  width: double.infinity, child: Text("Identifiant du deck :")),
              TextFormField(
                controller: _cardIdController,
                validator: validatorTextField,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: renderButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
