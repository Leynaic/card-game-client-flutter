import 'dart:math';

import 'package:card_game_flutter/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'cards.dart';

class DeckManagerWidget extends StatefulWidget {
  final Cards cards;
  final Function(Cards?) updateCard;

  const DeckManagerWidget(
      {Key? key, required this.cards, required this.updateCard})
      : super(key: key);

  @override
  State<DeckManagerWidget> createState() => _DeckManagerWidgetState();
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3});

  final double count;

  // 2. override transformInternal() method
  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t);
  }
}

class _DeckManagerWidgetState extends State<DeckManagerWidget>
    with TickerProviderStateMixin {
  late Cards _cards;

  // Boolean to active animation
  late bool _moveLeftDeckCardToRight;
  late bool _moveRightDeckCardToLeft;
  late bool _moveLeftDeckCardToBottom;

  late CardOfDeck? _leftCard;
  late CardOfDeck? _rightCard;

  // Duration
  late int _moveDuration;

  late bool _isGameVisible;
  late bool _isCardVisible;

  late String _resultText;
  late Color _resultColor;

  // Key to animate position
  final GlobalKey _leftDeckCard = GlobalKey();
  final GlobalKey _leftDeckCardForBottomLeft = GlobalKey();
  final GlobalKey _leftDeckCardForBottomRight = GlobalKey();
  final GlobalKey _bottomDeckLeftCard = GlobalKey();
  final GlobalKey _bottomDeckRightCard = GlobalKey();
  final GlobalKey _rightDeckCard = GlobalKey();

  // Shaking animation
  late final animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2));
  late final animationControllerDiscarded =
      AnimationController(vsync: this, duration: const Duration(seconds: 2));

  late final Animation<double> _sineAnimationDiscarded = Tween(
    begin: 0.0,
    end: 1.0,
    // 2. animate it with a CurvedAnimation
  ).animate(CurvedAnimation(
    parent: animationControllerDiscarded,
    // 3. use our SineCurve
    curve: const SineCurve(count: 3.0),
  ));

  late final Animation<double> _sineAnimation = Tween(
    begin: 0.0,
    end: 1.0,
    // 2. animate it with a CurvedAnimation
  ).animate(CurvedAnimation(
    parent: animationController,
    // 3. use our SineCurve
    curve: const SineCurve(count: 3.0),
  ));

  @override
  void initState() {
    super.initState();
    _cards = widget.cards;
    _moveDuration = 1;
    _moveLeftDeckCardToRight = false;
    _moveRightDeckCardToLeft = false;
    _moveLeftDeckCardToBottom = false;
    _isGameVisible = false;
    _isCardVisible = false;
    _leftCard = null;
    _rightCard = null;
    _resultText = "";
    _resultColor = Colors.orange;
    animationController.addStatusListener(_updateStatus);
    animationControllerDiscarded.addStatusListener(_updateStatusDiscarded);
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    animationControllerDiscarded.removeStatusListener(_updateStatusDiscarded);
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  void _updateStatusDiscarded(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationControllerDiscarded.reset();
    }
  }

  Widget buildCard({Key? key}) {
    return Image(
      key: key,
      width: 169,
      height: 244,
      image: const AssetImage('assets/images/back.png'),
    );
  }

  Widget animatedCard(Widget card, int offset) {
    return AnimatedBuilder(
      // 2. pass our custom animation as an argument
      animation: _sineAnimation,
      // 3. optimization: pass the given child as an argument
      child: card,
      builder: (context, child) {
        return Transform.translate(
          // 4. apply a translation as a function of the animation value
          offset: Offset(_sineAnimation.value * offset, 0),
          // 5. use the child widget
          child: child,
        );
      },
    );
  }

  Widget animatedDiscardedCard(Widget card, int offset) {
    return AnimatedBuilder(
      // 2. pass our custom animation as an argument
      animation: _sineAnimationDiscarded,
      // 3. optimization: pass the given child as an argument
      child: card,
      builder: (context, child) {
        return Transform.translate(
          // 4. apply a translation as a function of the animation value
          offset: Offset(_sineAnimationDiscarded.value * offset, 0),
          // 5. use the child widget
          child: child,
        );
      },
    );
  }

  Widget buildLeftDeckStack() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          animatedCard(buildCard(), -75),
          animatedCard(buildCard(), 150),
          AnimatedPositioned(
            left: _moveLeftDeckCardToBottom
                ? (_bottomDeckRightCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx -
                    (_leftDeckCardForBottomRight.currentContext!
                            .findRenderObject() as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx
                : 0,
            top: _moveLeftDeckCardToBottom
                ? (_bottomDeckRightCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dy -
                    (_leftDeckCardForBottomRight.currentContext!
                            .findRenderObject() as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dy
                : 0,
            duration: Duration(seconds: _moveDuration),
            child: buildCard(key: _leftDeckCardForBottomRight),
            onEnd: () {
              playBataille();
            },
          ),
          AnimatedPositioned(
            left: _moveLeftDeckCardToBottom
                ? (_bottomDeckLeftCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx -
                    (_leftDeckCardForBottomLeft.currentContext!
                            .findRenderObject() as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx
                : 0,
            top: _moveLeftDeckCardToBottom
                ? (_bottomDeckLeftCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dy -
                    (_leftDeckCardForBottomLeft.currentContext!
                            .findRenderObject() as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dy
                : 0,
            duration: Duration(seconds: _moveDuration),
            child: buildCard(key: _leftDeckCardForBottomLeft),
          ),
          AnimatedPositioned(
            left: _moveLeftDeckCardToRight
                ? (_rightDeckCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx -
                    (_leftDeckCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx
                : 0,
            duration: Duration(seconds: _moveDuration),
            child: buildCard(key: _leftDeckCard),
            onEnd: () {
              setState(() {
                _moveDuration = 0;
                _moveLeftDeckCardToRight = false;
                _isCardVisible = true;
              });
            },
          ),
          animatedCard(buildCard(), 50),
          animatedCard(buildCard(), -125),
          Positioned(
            left: 0,
            right: 0,
            bottom: -20.0,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 40.0,
                width: 40.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(_cards.cards.length.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRightDeckStack() {
    int realLength = _cards.discardedCards.length;
    if (_isGameVisible) realLength = realLength - 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          animatedDiscardedCard(buildCard(), -75),
          animatedDiscardedCard(buildCard(), 150),
          AnimatedPositioned(
            right: _moveRightDeckCardToLeft
                ? (_rightDeckCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx -
                    (_leftDeckCard.currentContext!.findRenderObject()
                            as RenderBox)
                        .localToGlobal(Offset.zero)
                        .dx
                : 0,
            top: 0,
            duration: Duration(seconds: _moveDuration),
            curve: Curves.fastLinearToSlowEaseIn,
            child: buildCard(key: _rightDeckCard),
            onEnd: () {
              setState(() {
                _moveDuration = 0;
                _moveRightDeckCardToLeft = false;
              });
            },
          ),
          animatedDiscardedCard(buildCard(), 75),
          animatedDiscardedCard(buildCard(), -150),
          buildLastCard(),
          Positioned(
            left: 0,
            right: 0,
            bottom: -20.0,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 40.0,
                width: 40.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      realLength.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLastCard() {
    CardOfDeck? lastDiscardedCard =
        _cards.discardedCards.isNotEmpty ? _cards.discardedCards.last : null;

    if (lastDiscardedCard == null) return Container();

    return Visibility(
        visible: _isCardVisible,
        child: Image(
          width: 169,
          height: 244,
          fit: BoxFit.scaleDown,
          image: AssetImage('assets/images/cards/' +
              lastDiscardedCard.value.toString() +
              '.png'),
        ),
    );
  }

  Widget buildHeader(String heading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        heading,
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: SelectableText(
              _cards.id,
              showCursor: false,
              onTap: () {
                Clipboard.setData(ClipboardData(text: _cards.id));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Identifiant copié')));
              },
            ),
          ),
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Column(
                children: [
                  buildHeader("Défausse"),
                  buildRightDeckStack(),
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: 'Remettre une carte à la fin du paquet',
                              child: ElevatedButton(
                                child: const Icon(Icons.arrow_back),
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.all(18),
                                    shape: const CircleBorder()),
                                onPressed: () {
                                  if (_moveRightDeckCardToLeft ||
                                      (_isGameVisible
                                          ? _cards.discardedCards.length - 2 ==
                                              0
                                          : _cards.discardedCards.isEmpty)) {
                                    return;
                                  }

                                  Requests.putCards(_cards.id).then((value) {
                                    setState(() {
                                      _cards = value;
                                      _moveDuration = 1;
                                      _moveRightDeckCardToLeft = true;
                                    });
                                  });
                                },
                              ),
                            ),
                            Tooltip(
                              message: 'Tout remettre dans le paquet',
                              child: ElevatedButton(
                                child: const Icon(Icons.restart_alt),
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.brown,
                                    padding: const EdgeInsets.all(18),
                                    shape: const CircleBorder()),
                                onPressed: () {
                                  if (_moveRightDeckCardToLeft ||
                                      (_isGameVisible
                                          ? _cards.discardedCards.length - 2 ==
                                              0
                                          : _cards.discardedCards.isEmpty)) {
                                    return;
                                  }

                                  Requests.putCards(_cards.id,
                                          nbCards: _cards.discardedCards.length)
                                      .then((value) {
                                    setState(() {
                                      _cards = value;
                                      _moveDuration = 1;
                                      _moveRightDeckCardToLeft = true;
                                    });
                                  });
                                },
                              ),
                            ),
                            Tooltip(
                              message: "Mélanger la défausse",
                              child: ElevatedButton(
                                  child: const Icon(Icons.shuffle),
                                  style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.pink,
                                      padding: const EdgeInsets.all(18),
                                      shape: const CircleBorder()),
                                  onPressed: () {
                                    Requests.shuffleCards(_cards.id,
                                            shuffleDiscard: true)
                                        .then((value) {
                                      setState(() {
                                        _cards = value;
                                      });
                                      animationControllerDiscarded.forward();
                                    });
                                  }),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  buildHeader("Pioche"),
                  buildLeftDeckStack(),
                  Flex(
                    direction: Axis.vertical,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Tooltip(
                                  message: 'Prendre une carte',
                                  child: ElevatedButton(
                                    child: const Icon(Icons.arrow_forward),
                                    style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.all(18),
                                        shape: const CircleBorder()),
                                    onPressed: () {
                                      if (_moveLeftDeckCardToRight ||
                                          _cards.cards.isEmpty) return;

                                      Requests.takeCards(_cards.id)
                                          .then((value) {
                                        setState(() {
                                          _cards = value;
                                          _isGameVisible = false;
                                          _moveDuration = 1;
                                          _moveLeftDeckCardToRight = true;
                                        });
                                      });
                                    },
                                  ),
                                ),
                                Tooltip(
                                  message: 'Mélanger le paquet',
                                  child: ElevatedButton(
                                    child: const Icon(Icons.shuffle),
                                    style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.orangeAccent,
                                        padding: const EdgeInsets.all(18),
                                        shape: const CircleBorder()),
                                    onPressed: () {
                                      Requests.shuffleCards(_cards.id)
                                          .then((value) {
                                        setState(() {
                                          _cards = value;
                                        });
                                        animationController.forward();
                                      });
                                    },
                                  ),
                                ),
                                Tooltip(
                                  message: 'Supprimer le paquet',
                                  child: ElevatedButton(
                                    child: const Icon(Icons.delete),
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.all(18),
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () {
                                      Requests.deleteCards(_cards.id)
                                          .then((value) {
                                        widget.updateCard(null);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                child: const Text(
                                    'Jouer à la bataille (simplifié)'),
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.all(18)),
                                onPressed: () {
                                  Requests.takeCards(_cards.id, nbCards: 2)
                                      .then((value) {
                                    setState(() {
                                      _isCardVisible = false;
                                      _isGameVisible = false;
                                      _cards = value;
                                      _moveDuration = 1;
                                      _moveLeftDeckCardToBottom = true;
                                      _leftCard = _cards.discardedCards
                                          .elementAt(
                                              _cards.discardedCards.length - 1);
                                      _rightCard = _cards.discardedCards
                                          .elementAt(
                                              _cards.discardedCards.length - 2);
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Opacity(
                    opacity: _isGameVisible ? 1 : 0,
                    child: Image(
                      key: _bottomDeckLeftCard,
                      width: 169,
                      height: 244,
                      image: AssetImage(_leftCard == null
                          ? 'assets/images/back.png'
                          : _leftCard!.image),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  const Text(
                    'Joueur',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Column(
                children: [
                  Opacity(
                    opacity: _isGameVisible ? 1 : 0,
                    child: Image(
                      key: _bottomDeckRightCard,
                      width: 169,
                      height: 244,
                      fit: BoxFit.scaleDown,
                      image: AssetImage(_rightCard == null
                          ? 'assets/images/back.png'
                          : _rightCard!.image),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  const Text(
                    'Ordinateur',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(_resultText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _resultColor,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void playBataille() {
    setState(() {
      _isCardVisible = false;
      _resultText = "";
      _isGameVisible = true;
      _moveDuration = 0;
      _moveLeftDeckCardToBottom = false;
    });

    int result = _leftCard!.isBetterThan(_rightCard!);

    setState(() {
      if (result == 0) {
        _resultText = "Il y a égalité.";
        _resultColor = Colors.orange;
      } else if (result == 1) {
        _resultText = "Vous avez gagné !";
        _resultColor = Colors.green;
      } else {
        _resultText = "Vous avez perdu !";
        _resultColor = Colors.redAccent;
      }
    });
  }
}
