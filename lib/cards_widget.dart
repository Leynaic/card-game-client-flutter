import 'package:card_game_flutter/cards.dart';
import 'package:card_game_flutter/requests.dart';
import 'package:flutter/material.dart';

class CardsWidget extends StatefulWidget {
  const CardsWidget({Key? key, required this.cards}) : super(key: key);
  final Cards cards;

  @override
  State<StatefulWidget> createState() => _CardsWidgetState();
}

class _CardsWidgetState extends State<CardsWidget> {
  void onPressedShuffle() async {
    await Requests.shuffleCards(widget.cards.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Column(
        children: [
          Text(
            "Mon paquet de carte",
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 20),
          Image.network("https://leynaic.fr/assets/cards/0.png"),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text("Mélanger le paquet"),
            onPressed: onPressedShuffle,
          ),
        ],
      ),
    );
  }
}
