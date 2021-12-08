class Cards {
  final String id;
  final List<CardOfDeck> cards;
  final List<CardOfDeck> discardedCards;

  const Cards({required this.id, required this.cards, required this.discardedCards});

  factory Cards.fromJson(Map<String, dynamic> json) {
    List cards = json['cards'];
    List discardedCards = json['discarded'];
    return Cards(
      id: json['id'] as String,
      cards: cards.map((e) => CardOfDeck.fromJson(e)).toList(),
      discardedCards: discardedCards.map((e) => CardOfDeck.fromJson(e)).toList(),
    );
  }
}

class CardOfDeck {
  final String name;
  final int value;
  final String image;

  const CardOfDeck({required this.name, required this.value, required this.image});

  factory CardOfDeck.fromJson(Map<String, dynamic> json) {
    return CardOfDeck(
      name: json['name'] as String,
      value: json['value'] as int,
      image: json['image'] as String,
    );
  }

  int isBetterThan(CardOfDeck other) {
    int realValue = value % 13;
    int otherRealValue = other.value % 13;

    // Fix value for AS, AS is stronger than all card in "La Bataille"
    if (realValue == 0) realValue = 13;
    if (otherRealValue == 0) otherRealValue = 13;

    // Compare card value
    if (realValue == otherRealValue) {
      return 0;
    } else if (realValue > otherRealValue) {
      return 1;
    } else {
      return -1;
    }
  }
}