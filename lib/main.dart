// Master Mind Game in Flutter
// imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// Entry point
void main() {
  runApp(const MyApp());
}

// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build method
  @override
  Widget build(BuildContext context) {
    // MaterialApp with theming
    return MaterialApp(
      title: 'Master Mind',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DifficultySelectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Difficulty Selection Page
class DifficultySelectionPage extends StatefulWidget {
  // Constructor
  const DifficultySelectionPage({super.key});

  // Create state
  @override
  State<DifficultySelectionPage> createState() => _DifficultySelectionPageState();
}

// State for Difficulty Selection Page
class _DifficultySelectionPageState extends State<DifficultySelectionPage> {
  // State variables
  int selectedAttempts = 10; // Default number of attempts
  int selectedColors = 6; // Default number of colors
  int selectedCodeLength = 4; // Default code length

  // List of all available colors
  final List<Color> allAvailableColors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.brown,
    Colors.orange,
    Colors.white,
    Colors.black,
  ];

  // Build method
  @override
  Widget build(BuildContext context) {
    // Scaffold with sliders and button
    return Scaffold(
      // App bar
      appBar: AppBar(title: const Text('Imposta difficoltà del gioco')), // App bar title
      // Body with sliders
      body: Padding(
        // Padding
        padding: const EdgeInsets.all(20.0), // Padding around content
        // Column with sliders and button
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          // Children widgets
          children: [
            // Slider for number of attempts
            Text(
              'Numero di tentativi: $selectedAttempts',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: selectedAttempts.toDouble(), // Current value
              min: 6,
              max: 12,
              divisions: 6, // Number of divisions
              label: selectedAttempts.toString(), // Label for current value
              // On change callback
              onChanged: (value) {
                setState(() {
                  selectedAttempts = value.toInt(); // Update state
                });
              },
            ),

            const SizedBox(height: 20), // Spacing

            Text(
              'Numero di colori disponibili: $selectedColors',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: selectedColors.toDouble(), // Current value
              min: 6,
              max: allAvailableColors.length.toDouble(), // Max value based on available colors length
              divisions: allAvailableColors.length - 6, // Number of divisions
              label: selectedColors.toString(), // Label for current value
              // On change callback
              onChanged: (value) {
                setState(() {
                  selectedColors = value.toInt(); // Update state
                });
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Lunghezza del codice da indovinare: $selectedCodeLength',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: selectedCodeLength.toDouble(), // Current value
              min: 4,
              max: 6,
              divisions: 2,
              label: selectedCodeLength.toString(),
              onChanged: (value) {
                setState(() {
                  selectedCodeLength = value.toInt();
                });
              },
            ),

            const SizedBox(height: 40),

            // Start Game button
            ElevatedButton(
              // On press callback to navigate to game page
              onPressed: () {
                // Navigate to MyHomePage with selected settings
                Navigator.pushReplacement(
                  context, // Replace current page
                  // New route
                  MaterialPageRoute(
                    // Build MyHomePage with selected settings
                    builder: (context) => MyHomePage(
                      title: 'Master Mind',
                      maxAttempts: selectedAttempts,
                      numColors: selectedColors,
                      codeLength: selectedCodeLength,
                    ),
                  ),
                );
              },
              // Button label
              child: const Text('Inizia il gioco'),
            ),
          ],
        ),
      ),
    );
  }
}

// Attempt data class
class _Attempt {
  // Fields for attempt
  final List<Color> guess; // Player's guess colors
  final int correctPosition; // Number of colors in correct position
  final int correctColor; // Number of correct colors in wrong position

  // Constructor
  _Attempt(this.guess, this.correctPosition, this.correctColor);
}

// Main Game Page
class MyHomePage extends StatefulWidget {
  // Fields for game settings
  final String title; // Page title
  final int maxAttempts; // Maximum number of attempts
  final int numColors; // Number of available colors
  final int codeLength; // Length of the secret code

  // Constructor
  const MyHomePage({
    super.key,
    required this.title,
    required this.maxAttempts,
    required this.numColors,
    required this.codeLength,
  });

  // Create state
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State for Main Game Page
class _MyHomePageState extends State<MyHomePage> {
  // State variables
  final Random _random = Random(); // Random generator
  int _attempts = 0; // Current attempt count
  String _message = ''; // Message to display
  bool _gameEnded = false; // Game end flag

  late List<Color> availableColors; // List of available colors
  late List<Color> _secretCode; // Secret code colors
  late List<Color> _playerGuess; // Player's current guess
  List<_Attempt> _history = []; // History of Player's attempts

  final ScrollController _historyController = ScrollController(); // Scroll controller for history list

  // Initialize state
  @override
  void initState() {
    super.initState(); // Initialize state

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Enable immersive mode. Hides system UI for full screen experience.

    // Set available colors based on selected number
    availableColors = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.brown,
      Colors.orange,
      Colors.white,
      Colors.black,
    ].sublist(0, widget.numColors);

    _generateSecretCode(); // Generate secret code
  }

  @override
  void dispose() {
    // Restore system UI on dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
        overlays: SystemUiOverlay.values);
    _historyController.dispose(); // Dispose scroll controller
    super.dispose(); // Call super dispose
  }

  // Generate secret code
  void _generateSecretCode() {
    // Generate random secret code
    _secretCode = List.generate(
      widget.codeLength, // Length of the code
      (_) => availableColors[_random.nextInt(availableColors.length)], // Random color from available colors
    );
    _message = 'Tocca i cerchi per scegliere i colori!'; // Initial message
    _attempts = 0; // Reset attempts
    _playerGuess = List.filled(widget.codeLength, Colors.grey); // Initialize player guess with list of grey colors
    _history = []; // Clear history
    _gameEnded = false; // Reset game end flag
  }

  // Change color in player's guess
  void _changeColor(int index) {
    if (_gameEnded) return; // Do nothing if game has ended
    // Cycle through available colors
    setState(() {
      final current = _playerGuess[index]; // Current color at index
      final currentIndex = availableColors.indexOf(current); // Index of current color in available colors
      final nextIndex = (currentIndex == -1) ? 0 : (currentIndex + 1) % availableColors.length; // Next index in available colors. Wrap around if at end
      _playerGuess[index] = availableColors[nextIndex]; // Update player's guess with next color
    });
  }

  // Check player's guess against secret code
  void _checkGuess() {
    if (_gameEnded) return; // Do nothing if game has ended

    // Ensure all colors are selected
    if (_playerGuess.contains(Colors.grey)) {
      // Show message if not all colors are selected
      setState(() {
        _message = 'Completa tutti i colori prima di verificare!';
      });
      return;
    }

    // Calculate feedback
    int correctPosition = 0; // Colors in correct position
    int correctColor = 0; // Correct colors in wrong position

    List<Color> tempSecret = List.from(_secretCode); // Temporary copy of secret code
    List<Color> tempGuess = List.from(_playerGuess); // Temporary copy of player's guess

    // correct position
    for (int i = 0; i < widget.codeLength; i++) {
      // if color and position match between guess and secret codes
      if (tempGuess[i] == tempSecret[i]) {
        correctPosition++; // Increment correct position count
        tempSecret[i] = Colors.transparent; // Mark as counted
        tempGuess[i] = Colors.transparent; // Mark as counted
      }
    }

    // correct color but wrong position
    for (int i = 0; i < widget.codeLength; i++) {
      // if color exists in secret code but in different position
      if (tempGuess[i] != Colors.transparent &&
          tempSecret.contains(tempGuess[i])) {
        correctColor++; // Increment correct color count
        tempSecret[tempSecret.indexOf(tempGuess[i])] = Colors.transparent; // Mark as counted
      }
    }

    // Update state with feedback
    setState(() {
      _attempts++; // Increment attempt count
      _history.insert(_history.length, _Attempt(List.from(_playerGuess), correctPosition, correctColor)); // Add attempt to history

      // Check for win or loss
      if (correctPosition == widget.codeLength) { // All colors correct and in correct position
        _message = 'Hai indovinato il codice in $_attempts tentativi!';
        _gameEnded = true;
      } else if (_attempts >= widget.maxAttempts) { // Max attempts reached
        _message = 'Hai perso! Il codice era:';
        _gameEnded = true;
      } else {
        _message =
            'Tentativo $_attempts: $correctPosition colori al posto giusto, $correctColor colore/i in posizione sbagliata'; // Feedback message
        _playerGuess = List.filled(widget.codeLength, Colors.grey); // Reset player's guess for next attempt
      }

      WidgetsBinding.instance.addPostFrameCallback((_) { // Scroll to bottom of history after frame is rendered
        if (_historyController.hasClients) { // Check if controller has clients
          _historyController.animateTo( // Scroll to bottom
            _historyController.position.maxScrollExtent, // Scroll position
            duration: const Duration(milliseconds: 200), // Animation duration
            curve: Curves.easeOut, // Animation curve
          );
        }
      });
    });
  }

  // Restart the game by navigating back to difficulty selection
  void _restartGame() {
    // Navigate back to DifficultySelectionPage
    Navigator.pushReplacement(
      context, // Replace current page
      MaterialPageRoute( // New route
        builder: (context) => const DifficultySelectionPage(), // Build DifficultySelectionPage
      ),
    );
  }

  // Show game rules dialog
  void _showRulesDialog() {
    // Show AlertDialog with game rules
    showDialog(
      context: context,
      // Build AlertDialog
      builder: (context) => AlertDialog(
        title: const Text('Regole del gioco'),
        content: SingleChildScrollView( // Scrollable content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
            children: [
              Text('1. Il computer genera un codice segreto di ${widget.codeLength} colori.'),
              const SizedBox(height: 8),
              Text('2. Puoi usare solo i primi ${widget.numColors} colori.'),
              const SizedBox(height: 8),
              const Text('3. Tocca i cerchi per cambiare colore.'),
              const SizedBox(height: 8),
              const Text(
                '4. Dopo ogni tentativo, ricevi un feedback:\n'
                '   • Rosso: colore corretto nella posizione corretta.\n'
                '   • Bianco: colore corretto, ma in posizione sbagliata.\n'
                '   • Grigio chiaro: nessun suggerimento.\n'
                '(La posizione dei colori del feedback non sono le stesse di quelle della giocata.)',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 8),
              Text('5. Vinci se indovini tutti e ${widget.codeLength} i colori al posto giusto!'),
              const SizedBox(height: 8),
              Text('6. Hai fino a ${widget.maxAttempts} tentativi.'),
            ],
          ),
        ),
        // Dialog actions
        actions: [
          TextButton( // Close button
            onPressed: Navigator.of(context).pop, // Close dialog on press. Returns to previous screen
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  // Build history of attempts
  Widget _buildHistory() {
    return ListView.builder( // Build list of attempts
      controller: _historyController, // Scroll controller for history
      shrinkWrap: true, // Shrink to fit content
      itemCount: _history.length, // Number of attempts
      itemBuilder: (context, index) { // Build each attempt
        final attempt = _history[index]; // Get attempt data
        List<Widget> indicators = []; // List of feedback indicators

        // Correct position indicators
        for (int i = 0; i < attempt.correctPosition; i++) { // Correct position
          // Add red indicator for correct position
          indicators.add(Container(
            width: 10,
            height: 10,
            color: Colors.red,
            margin: const EdgeInsets.symmetric(horizontal: 2), // Spacing between indicators
          ));
        }
        // Correct color but wrong position
        for (int i = 0; i < attempt.correctColor; i++) {
          indicators.add(Container(
            width: 10,
            height: 10,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 2),
          ));
        }
        // Fill remaining indicators with grey
        while (indicators.length < widget.codeLength) {
          indicators.add(Container(
            width: 10,
            height: 10,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 2),
          ));
        }

        // Return row for each attempt
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4), // Spacing between attempts
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
            children: [
              // Display guessed colors
              ...attempt.guess.map((c) => Container( // Circle for each guessed color
                margin: const EdgeInsets.all(4), // Spacing around circle
                width: 25,
                height: 25,
                decoration: BoxDecoration( // Decoration for circle
                  color: c, // Circle color
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              )),
              // Spacing between guess and indicators
              const SizedBox(width: 10),
              ...indicators, // Display feedback indicators
            ],
          ),
        );
      },
    );
  }

  // Build method for main game page
  @override
  Widget build(BuildContext context) {
    // Scaffold with app bar and body
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [ // Help button
          IconButton( // Help icon button
            icon: const Icon(Icons.help_outline), // Help icon
            onPressed: _showRulesDialog, // Show rules dialog on press
          ),
        ],
      ),
      body: Padding( // Padding around content
        padding: const EdgeInsets.all(16.0), // Padding value. All sides 16
        child: Column( // Column layout
          children: [ // Children widgets
            const SizedBox(height: 10), // Spacing
            Expanded( // Expanded to fill available space
              child: _buildHistory(), // Build history of attempts
            ),

            const SizedBox(height: 6),

            if (!_gameEnded) // Show color selection only if game is not ended
              LayoutBuilder( // LayoutBuilder to adapt circle sizes
                builder: (context, contraints) { // Get constraints
                  final avalableWidth = contraints.maxWidth - 32; // Available width minus padding
                  const spacingPerCircle = 16; // Spacing between circles
                  final maxCircleSize = (avalableWidth - (widget.codeLength - 1) * spacingPerCircle) / widget.codeLength; // Calculate max circle size based on available width and spacing
                  final circleSize = maxCircleSize.clamp(40.0, 60.0); // Clamp circle size between 40 and 60

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center circles horizontally
                    children: List.generate(widget.codeLength, (index) { // Generate circles for player's guess
                      // Circle for each color in player's guess
                      return GestureDetector(
                        onTap: () => _changeColor(index), // Change color on tap
                        child: Container(
                          margin: const EdgeInsets.all(8), // Spacing around circle
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration( // Decoration for circle
                            color: _playerGuess[index], // Circle color
                            shape: BoxShape.circle, // Circle shape
                            border: Border.all(color: Colors.grey.shade400, width: 2), // Border around circle
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon( // Button to check guess or restart game
              onPressed: _gameEnded ? _restartGame : _checkGuess, // Callback based on game state. Restart if ended or check guess if not ended
              icon: Icon(_gameEnded ? Icons.refresh : Icons.check_circle_outline), // Icon based on game state. Refresh if ended or check if not ended
              label: Text(_gameEnded ? 'Rigioca' : 'Verifica sequenza'), // Label based on game state. "Rigioca" if ended or "Verifica sequenza" if not ended
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (_message.contains('codice era')) // Show secret code if game is lost
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _secretCode.map((color) { // Display each color in secret code
                    // Circle for each color in secret code
                    return Container(
                      margin: const EdgeInsets.all(4),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                    );
                  }).toList(), // Convert map to list
                ),
              ),
          ],
        ),
      ),
    );
  }
}