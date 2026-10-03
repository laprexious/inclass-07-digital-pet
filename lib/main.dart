import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead. 
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Digital Pet')
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the configuration for the state. It holds the values that
  // affect how the page looks.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _petName = "Jabarkus";
  int _happiness = 50;
  int _hunger = 50;
  bool _gameOver = false;
  bool _hasWon = false;
  Timer? _hungerTimer;
  Timer? _highMoodTimer;
  int _clampMeter(int value) => value.clamp(0, 100).toInt();

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    final nextHunger = _clampMeter(_hunger - 10);
    final happinessChange = nextHunger < 30 ? -20 : 10;
    final nextHappiness = _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
    });
    _updateOutcome();
  }

  void _playPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _happiness = _clampMeter(_happiness + 10);
      _hunger = _clampMeter(_hunger + 5);
    });
    _updateOutcome();
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon) return;

    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _hungerTimer?.cancel();
      setState(() => _gameOver = true);
      return;
    }

    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;
      if (!mounted || _gameOver || _happiness <= 80) return;
      setState(() => _hasWon = true);
      _hungerTimer?.cancel();
    });
  }

  final TextEditingController _nameController = TextEditingController();

  //color change based on mood//
  Color get _moodColor {
    if (_happiness > 70) return const Color.fromARGB(253, 76, 175, 79);
    if (_happiness >= 30) return const Color.fromARGB(255, 255, 235, 59);
    return const Color.fromARGB(255, 244, 67, 54);
  }
  double get _petScale => _happiness > 70 ? 1.06 : _happiness < 30 ? 0.94 : 1.0;

  String get _petMessage {
    if (_gameOver) return 'I need a rest.';
    if (_hasWon) return 'Best day ever!';
    if (_hunger > 80) return "I'm starving!";
    if (_happiness <= 30) return 'Play with me?';
    return "Hi, I'm $_petName!";
  }

  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon) {
        timer.cancel();
        return;
      } 
      setState(() {
        if (_hunger + 5 > 100) {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        } else {
          _hunger += 5;
        }
      });
      _updateOutcome();
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }
  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
    });

    _updateOutcome();
  }
  //restart logic//
  void _restartSession() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
    });

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_hunger + 5 > 100) {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        } else {
          _hunger += 5;
        }
      });

      _updateOutcome();
    });
  }
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the
        // AppBar change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children.
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _petName = _nameController.text;
                });
              },
              child: const Text('Confirm Name'),
            ),
            AnimatedScale(
              scale: _petScale,
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(_moodColor, BlendMode.modulate),
                child: Image.asset('assets/pet-insect.png', width: 150, height: 150),
              ),
            ),

            AnimatedSwitcher(
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
              child: Text(_petMessage, key: ValueKey(_petMessage)),
            ),
            Text(_happiness > 70 ? 'Happy' : _happiness < 30 ? 'Sad' : 'Okay'),
            Text('Happiness: $_happiness'),
            LinearProgressIndicator(
              value: _happiness / 100,
            ),
             Text('Hunger: $_hunger'),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _hunger / 100),
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(value: value),
            ),
            ElevatedButton(
              onPressed: _feedPet,
              child: const Text('Feed'),
            ),
            ElevatedButton(
              onPressed: _playPet,
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: _resetPet,
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: _restartSession,
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}