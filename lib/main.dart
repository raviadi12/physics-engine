import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'components/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    // Add this line
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );
  runApp(
    MaterialApp(
      home: GameScreen(),
    ),
  );
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final game = MyPhysicsGame(
              screenWidth: screenWidth, screenHeight: screenHeight);
          return GameWidget(game: game);
        },
      ),
    );
  }
}
