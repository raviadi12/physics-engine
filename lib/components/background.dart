import 'dart:math';
import 'package:flame/components.dart';
import 'game.dart';
import 'dart:ui' as ui;

class Background extends Component with HasGameReference<MyPhysicsGame> {
  Background({
    required this.sprite,
    required this.repeatX,
    required this.repeatY,
    this.offsetX = 0.0,
    this.offsetY = 0.0, // Added offsetY parameter
  });

  final Sprite sprite;
  final int repeatX;
  final int repeatY;
  final double offsetX;
  final double offsetY; // Added offsetY property

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);

    final backgroundWidth =
        max(game.camera.visibleWorldRect.width, game.size.x);
    final backgroundHeight =
        max(game.camera.visibleWorldRect.height, game.size.y);

    final scale = backgroundWidth / sprite.srcSize.x;
    final scaley = backgroundHeight / sprite.srcSize.y;

    for (var i = 0; i < repeatX; i++) {
      sprite.render(
        canvas,
        position: Vector2(
          offsetX + i * sprite.srcSize.x * scale,
          offsetY + i * sprite.srcSize.y * scale, // Use offsetY here,
        ),
        size: Vector2(sprite.srcSize.x * scale, backgroundHeight * scaley),
      );
    }
  }
}

/*
Vector2.all(max(
      game.camera.visibleWorldRect.width,
      game.camera.visibleWorldRect.height,
    ));

*/