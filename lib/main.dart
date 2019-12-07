import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final homePageKey = GlobalKey();

const kColors = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MasterMind',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.white,
      ),
      home: MyHomePage(key: homePageKey),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

List<Color> generateRandom() {
  List<Color> colors = [];
  for (int i = 0; i < 4; i++) {
    colors.add(kColors[Random().nextInt(kColors.length)]);
  }
  return colors;
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<Color>> previousGuesses = [];
  List<Color> secret = generateRandom();
  bool finished = false;

  void resetState() {
    setState(() {
      previousGuesses = [];
      finished = false;
      secret = generateRandom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MasterMind 🧐'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("Reset game?"),
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () => Navigator.pop(context, true),
                            )
                          ],
                        ));
              if (confirm) {
                resetState();
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: previousGuesses.length + 1,
        itemBuilder: (context, index) {
          Widget r;
          if (index == previousGuesses.length) {
            final guess = index == 0
                ? Guess(isCurrent: true)
                : Guess(isCurrent: true, guess: previousGuesses[index - 1]);
            r = !finished
                ? guess
                : GestureDetector(
                    onTap: () {
                      resetState();
                    },
                    child: Center(
                        child: Text(
                            'Solved with ${previousGuesses.length} guesses! '
                            'Click to restart.')));
          } else {
            r = Guess(
              isCurrent: false,
              guess: previousGuesses[index],
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: r,
          );
        },
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

const defaultGuesses = [Colors.white, Colors.white, Colors.white, Colors.white];

class Guess extends StatefulWidget {
  final bool isCurrent;
  final List<Color> guess;

  Guess({Key key, this.isCurrent, this.guess = defaultGuesses})
      : super(key: key);

  @override
  _GuessState createState() => _GuessState(guess);
}

class _GuessState extends State<Guess> {
  List<Color> guess;

  _GuessState(guesses) : guess = List.from(guesses);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    _MyHomePageState homePageState = homePageKey.currentState;
    guess.asMap().forEach((idx, g) {
      items.add(GestureDetector(
        onTap: () {
          if (!widget.isCurrent) {
            return;
          }
          setState(() {
            guess[idx] = kColors[(kColors.indexOf(g) + 1) % kColors.length];
          });
        },
        child: Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: g, boxShadow: [
            BoxShadow(blurRadius: 10.0, color: Colors.black.withOpacity(0.3))
          ]),
          width: 65,
          height: 65,
        ),
      ));
    });
    if (widget.isCurrent) {
      items.add(IconButton(
          icon: Icon(Icons.done),
          onPressed: () {
            homePageState.setState(() {
              homePageState.previousGuesses.add(guess);
            });
          }));
    } else {
      int correct = 0;
      for (int i = 0; i < guess.length; i++) {
        if (guess[i] == homePageState.secret[i]) {
          correct++;
        }
      }
      int correctColors = 0;
      final secretCounts = getCounts(homePageState.secret);
      final guessCounts = getCounts(guess);
      for (Color c in secretCounts.keys) {
        print(guessCounts);
        print(secretCounts);
        correctColors += min(guessCounts[c], secretCounts[c]);
      }
      items.add(Container(
        width: 50,
        child: Text(
          '$correct   $correctColors',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ));
      if (correct == 4) {
        setState(() {
          homePageState.finished = true;
        });
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items,
    );
  }
}

Map<Color, int> getCounts(List<Color> guess) {
  Map<Color, int> counts = {};
  for (Color c in kColors) {
    counts[c] = 0;
  }
  for (Color c in guess) {
    counts[c]++;
  }
  return counts;
}
