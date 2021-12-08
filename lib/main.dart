import 'package:card_game_flutter/create_deck_widget.dart';
import 'package:card_game_flutter/deck_manager_widget.dart';

import 'cards.dart';
import 'find_deck_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu de carte',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(title: 'Jeu de carte'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Cards? _cards;

  void updateCard(Cards? cards) {
    setState(() {
      _cards = cards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              widget.title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 40),
                  if (_cards == null) CreateDeckWidget(updateCard: updateCard),
                  if (_cards == null) const SizedBox(height: 10),
                  if (_cards == null) FindDeckWidget(updateCard: updateCard),
                  if (_cards != null)
                    DeckManagerWidget(cards: _cards!, updateCard: updateCard),
                ],
              ),
            ),
          ),
        ));
  }
}
