import 'dart:math';

import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  _HistoryItem _genNextPoint(
    int currentPoint,
    int bet,
    bool willBeUp,
  ) {
    var nextPoint = Random().nextInt(10000);
    while (nextPoint == currentPoint) {
      nextPoint = Random().nextInt(10000);
    }

    final isWin = nextPoint > currentPoint && willBeUp ||
        nextPoint < currentPoint && !willBeUp;
    return _HistoryItem(
      point: nextPoint,
      bet: bet,
      isWin: isWin,
    );
  }

  int _getNumberRadix(int number) {
    var radix = 1;
    while (number >= 10) {
      number ~/= 10;
      radix *= 10;
    }
    return radix;
  }

  @override
  Widget build(BuildContext context) {
    final messangerKey = GlobalKey<ScaffoldMessengerState>();
    final loseNotifier = ValueNotifier<bool>(false);
    final scoreNotifier = ValueNotifier<int>(10);
    final scoreHistory = <_HistoryItem>[];
    final betNotifier = ValueNotifier<int>(0);
    final currentPointNotifier = ValueNotifier<int>(
      Random().nextInt(10000),
    );
    return MaterialApp(
      scaffoldMessengerKey: messangerKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 16,
          ),
          child: ValueListenableBuilder(
            valueListenable: loseNotifier,
            builder: (context, lose, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: scoreNotifier,
                    builder: (context, score, child) {
                      return Text(
                        'Score: \$$score',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ValueListenableBuilder(
                    valueListenable: currentPointNotifier,
                    builder: (context, score, child) {
                      return Text(
                        '\$$score',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 54,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 64),
                  const Text(
                    'set your bet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: betNotifier,
                    builder: (context, bet, child) {
                      debugPrint('bet: $bet');
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (lose) return;

                              if (bet > 0) {
                                final step = _getNumberRadix(bet);
                                betNotifier.value = bet - step;
                                if (betNotifier.value > scoreNotifier.value) {
                                  betNotifier.value = scoreNotifier.value;
                                }
                              }
                            },
                            child: Text(
                              '-',
                              style: TextStyle(
                                color: bet == 0 || lose
                                    ? Colors.white30
                                    : Colors.grey,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Text(
                            '\$$bet',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 32),
                          GestureDetector(
                            onTap: () {
                              if (lose) return;

                              if (bet < scoreNotifier.value) {
                                final step = _getNumberRadix(bet);
                                betNotifier.value = bet + step;
                                if (betNotifier.value > scoreNotifier.value) {
                                  betNotifier.value = scoreNotifier.value;
                                }
                              }
                            },
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: bet == scoreNotifier.value || lose
                                    ? Colors.white30
                                    : Colors.grey,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (lose) return;

                            if (betNotifier.value > 0) {
                              final next = _genNextPoint(
                                currentPointNotifier.value,
                                betNotifier.value,
                                false,
                              );

                              debugPrint('next1: $next');

                              scoreHistory.add(next);
                              currentPointNotifier.value = next.point;
                              scoreNotifier.value +=
                                  next.isWin ? next.bet : -next.bet;
                              betNotifier.value = next.bet;
                              betNotifier.notifyListeners();

                              if (scoreNotifier.value <= 0) {
                                messangerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content: Text('You lose'),
                                  ),
                                );
                                if (scoreNotifier.value < betNotifier.value) {
                                  betNotifier.value = scoreNotifier.value;
                                }
                                loseNotifier.value = true;
                              }

                              return;
                            }

                            messangerKey.currentState?.showSnackBar(
                              const SnackBar(
                                content: Text('Please set your bet'),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              lose ? Colors.grey : Colors.red,
                            ),
                          ),
                          child: const Text('down'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (lose) return;

                            if (betNotifier.value > 0) {
                              final next = _genNextPoint(
                                currentPointNotifier.value,
                                betNotifier.value,
                                true,
                              );

                              debugPrint('next2: $next');

                              scoreHistory.add(next);
                              currentPointNotifier.value = next.point;
                              scoreNotifier.value +=
                                  next.isWin ? next.bet : -next.bet;
                              betNotifier.value = next.bet;
                              betNotifier.notifyListeners();

                              if (scoreNotifier.value <= 0) {
                                messangerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content: Text('You lose'),
                                  ),
                                );
                                if (scoreNotifier.value < betNotifier.value) {
                                  betNotifier.value = scoreNotifier.value;
                                }
                                loseNotifier.value = true;
                              }

                              return;
                            }

                            messangerKey.currentState?.showSnackBar(
                              const SnackBar(
                                content: Text('Please set your bet'),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              lose ? Colors.grey : Colors.green,
                            ),
                          ),
                          child: const Text('up'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 96),
                  ValueListenableBuilder(
                    valueListenable: loseNotifier,
                    builder: (context, lose, child) {
                      return Visibility(
                        visible: lose,
                        child: Column(
                          children: [
                            const Text(
                              'Unfortunately, you lose all your money :(',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                scoreHistory.clear();
                                scoreNotifier.value = 10;
                                betNotifier.value = 0;
                                currentPointNotifier.value =
                                    Random().nextInt(10000);
                                loseNotifier.value = false;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.green,
                                ),
                              ),
                              child: const Text('Play again'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryItem {
  _HistoryItem({
    required this.point,
    required this.bet,
    required this.isWin,
  });

  final int point;
  final int bet;
  final bool isWin;

  @override
  String toString() {
    return 'point: $point, bet: $bet, isWin: $isWin';
  }
}
