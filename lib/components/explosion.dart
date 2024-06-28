import 'package:flame/components.dart';

class Explosion extends SpriteAnimationComponent {
  Explosion({
    required super.position,
    required List<Sprite> explosionSprites,
    super.size, // Make size nullable
  }) : super(
          animation: SpriteAnimation.spriteList(
            explosionSprites,
            stepTime: 0.1,
            loop: false,
          ),
          anchor: Anchor.center,
          removeOnFinish: true,
        ) {
    this.size = Vector2(15, 15); // Initialize size if null
  }
}
