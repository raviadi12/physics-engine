lib\components\background.dart

```dart
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
```

lib\components\body_component_with_user_data.dart

```dart
import 'package:flame_forge2d/flame_forge2d.dart';

class BodyComponentWithUserData extends BodyComponent {
  BodyComponentWithUserData({
    super.key,
    super.bodyDef,
    super.children,
    super.fixtureDefs,
    super.paint,
    super.priority,
    super.renderBody,
  });

  @override
  Body createBody() {
    final body = world.createBody(super.bodyDef!)..userData = this;
    fixtureDefs?.forEach(body.createFixture);
    return body;
  }
}

```

lib\components\brick.dart

```dart
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'body_component_with_user_data.dart';

const brickScale = 0.5;

enum BrickType {
  explosive(density: 1, friction: 0.5),
  glass(density: 0.5, friction: 0.2),
  metal(density: 1, friction: 0.4),
  stone(density: 2, friction: 1),
  wood(density: 0.25, friction: 0.6);

  final double density;
  final double friction;

  const BrickType({required this.density, required this.friction});
  static BrickType get randomType => values[Random().nextInt(values.length)];
}

enum BrickSize {
  size70x70(ui.Size(70, 70)),
  size140x70(ui.Size(140, 70)),
  size220x70(ui.Size(220, 70)),
  size70x140(ui.Size(70, 140)),
  size140x140(ui.Size(140, 140)),
  size220x140(ui.Size(220, 140)),
  size140x220(ui.Size(140, 220)),
  size70x220(ui.Size(70, 220));

  final ui.Size size;

  const BrickSize(this.size);
  static BrickSize get randomSize => values[Random().nextInt(values.length)];
}

enum BrickDamage { none, some, lots }

Map<BrickDamage, String> brickFileNames(BrickType type, BrickSize size) {
  return switch ((type, size)) {
    (BrickType.explosive, BrickSize.size140x70) => {
        BrickDamage.none: 'elementExplosive009.png',
        BrickDamage.some: 'elementExplosive012.png',
        BrickDamage.lots: 'elementExplosive050.png',
      },
    (BrickType.glass, BrickSize.size140x70) => {
        BrickDamage.none: 'elementGlass010.png',
        BrickDamage.some: 'elementGlass013.png',
        BrickDamage.lots: 'elementGlass048.png',
      },
    (BrickType.metal, BrickSize.size140x70) => {
        BrickDamage.none: 'elementMetal009.png',
        BrickDamage.some: 'elementMetal012.png',
        BrickDamage.lots: 'elementMetal050.png',
      },
    (BrickType.stone, BrickSize.size140x70) => {
        BrickDamage.none: 'elementStone009.png',
        BrickDamage.some: 'elementStone012.png',
        BrickDamage.lots: 'elementStone047.png',
      },
    (BrickType.wood, BrickSize.size140x70) => {
        BrickDamage.none: 'elementWood011.png',
        BrickDamage.some: 'elementWood014.png',
        BrickDamage.lots: 'elementWood054.png',
      },
    (BrickType.explosive, BrickSize.size70x70) => {
        BrickDamage.none: 'elementExplosive011.png',
        BrickDamage.some: 'elementExplosive014.png',
        BrickDamage.lots: 'elementExplosive049.png',
      },
    (BrickType.glass, BrickSize.size70x70) => {
        BrickDamage.none: 'elementGlass011.png',
        BrickDamage.some: 'elementGlass012.png',
        BrickDamage.lots: 'elementGlass046.png',
      },
    (BrickType.metal, BrickSize.size70x70) => {
        BrickDamage.none: 'elementMetal011.png',
        BrickDamage.some: 'elementMetal014.png',
        BrickDamage.lots: 'elementMetal049.png',
      },
    (BrickType.stone, BrickSize.size70x70) => {
        BrickDamage.none: 'elementStone011.png',
        BrickDamage.some: 'elementStone014.png',
        BrickDamage.lots: 'elementStone046.png',
      },
    (BrickType.wood, BrickSize.size70x70) => {
        BrickDamage.none: 'elementWood010.png',
        BrickDamage.some: 'elementWood013.png',
        BrickDamage.lots: 'elementWood045.png',
      },
    (BrickType.explosive, BrickSize.size220x70) => {
        BrickDamage.none: 'elementExplosive013.png',
        BrickDamage.some: 'elementExplosive016.png',
        BrickDamage.lots: 'elementExplosive051.png',
      },
    (BrickType.glass, BrickSize.size220x70) => {
        BrickDamage.none: 'elementGlass014.png',
        BrickDamage.some: 'elementGlass017.png',
        BrickDamage.lots: 'elementGlass049.png',
      },
    (BrickType.metal, BrickSize.size220x70) => {
        BrickDamage.none: 'elementMetal013.png',
        BrickDamage.some: 'elementMetal016.png',
        BrickDamage.lots: 'elementMetal051.png',
      },
    (BrickType.stone, BrickSize.size220x70) => {
        BrickDamage.none: 'elementStone013.png',
        BrickDamage.some: 'elementStone016.png',
        BrickDamage.lots: 'elementStone048.png',
      },
    (BrickType.wood, BrickSize.size220x70) => {
        BrickDamage.none: 'elementWood012.png',
        BrickDamage.some: 'elementWood015.png',
        BrickDamage.lots: 'elementWood047.png',
      },
    (BrickType.explosive, BrickSize.size70x140) => {
        BrickDamage.none: 'elementExplosive017.png',
        BrickDamage.some: 'elementExplosive022.png',
        BrickDamage.lots: 'elementExplosive052.png',
      },
    (BrickType.glass, BrickSize.size70x140) => {
        BrickDamage.none: 'elementGlass018.png',
        BrickDamage.some: 'elementGlass023.png',
        BrickDamage.lots: 'elementGlass050.png',
      },
    (BrickType.metal, BrickSize.size70x140) => {
        BrickDamage.none: 'elementMetal017.png',
        BrickDamage.some: 'elementMetal022.png',
        BrickDamage.lots: 'elementMetal052.png',
      },
    (BrickType.stone, BrickSize.size70x140) => {
        BrickDamage.none: 'elementStone017.png',
        BrickDamage.some: 'elementStone022.png',
        BrickDamage.lots: 'elementStone049.png',
      },
    (BrickType.wood, BrickSize.size70x140) => {
        BrickDamage.none: 'elementWood016.png',
        BrickDamage.some: 'elementWood021.png',
        BrickDamage.lots: 'elementWood048.png',
      },
    (BrickType.explosive, BrickSize.size140x140) => {
        BrickDamage.none: 'elementExplosive018.png',
        BrickDamage.some: 'elementExplosive023.png',
        BrickDamage.lots: 'elementExplosive053.png',
      },
    (BrickType.glass, BrickSize.size140x140) => {
        BrickDamage.none: 'elementGlass019.png',
        BrickDamage.some: 'elementGlass024.png',
        BrickDamage.lots: 'elementGlass051.png',
      },
    (BrickType.metal, BrickSize.size140x140) => {
        BrickDamage.none: 'elementMetal018.png',
        BrickDamage.some: 'elementMetal023.png',
        BrickDamage.lots: 'elementMetal053.png',
      },
    (BrickType.stone, BrickSize.size140x140) => {
        BrickDamage.none: 'elementStone018.png',
        BrickDamage.some: 'elementStone023.png',
        BrickDamage.lots: 'elementStone050.png',
      },
    (BrickType.wood, BrickSize.size140x140) => {
        BrickDamage.none: 'elementWood017.png',
        BrickDamage.some: 'elementWood022.png',
        BrickDamage.lots: 'elementWood049.png',
      },
    (BrickType.explosive, BrickSize.size220x140) => {
        BrickDamage.none: 'elementExplosive019.png',
        BrickDamage.some: 'elementExplosive024.png',
        BrickDamage.lots: 'elementExplosive054.png',
      },
    (BrickType.glass, BrickSize.size220x140) => {
        BrickDamage.none: 'elementGlass020.png',
        BrickDamage.some: 'elementGlass025.png',
        BrickDamage.lots: 'elementGlass052.png',
      },
    (BrickType.metal, BrickSize.size220x140) => {
        BrickDamage.none: 'elementMetal019.png',
        BrickDamage.some: 'elementMetal024.png',
        BrickDamage.lots: 'elementMetal054.png',
      },
    (BrickType.stone, BrickSize.size220x140) => {
        BrickDamage.none: 'elementStone019.png',
        BrickDamage.some: 'elementStone024.png',
        BrickDamage.lots: 'elementStone051.png',
      },
    (BrickType.wood, BrickSize.size220x140) => {
        BrickDamage.none: 'elementWood018.png',
        BrickDamage.some: 'elementWood023.png',
        BrickDamage.lots: 'elementWood050.png',
      },
    (BrickType.explosive, BrickSize.size70x220) => {
        BrickDamage.none: 'elementExplosive020.png',
        BrickDamage.some: 'elementExplosive025.png',
        BrickDamage.lots: 'elementExplosive055.png',
      },
    (BrickType.glass, BrickSize.size70x220) => {
        BrickDamage.none: 'elementGlass021.png',
        BrickDamage.some: 'elementGlass026.png',
        BrickDamage.lots: 'elementGlass053.png',
      },
    (BrickType.metal, BrickSize.size70x220) => {
        BrickDamage.none: 'elementMetal020.png',
        BrickDamage.some: 'elementMetal025.png',
        BrickDamage.lots: 'elementMetal055.png',
      },
    (BrickType.stone, BrickSize.size70x220) => {
        BrickDamage.none: 'elementStone020.png',
        BrickDamage.some: 'elementStone025.png',
        BrickDamage.lots: 'elementStone052.png',
      },
    (BrickType.wood, BrickSize.size70x220) => {
        BrickDamage.none: 'elementWood019.png',
        BrickDamage.some: 'elementWood024.png',
        BrickDamage.lots: 'elementWood051.png',
      },
    (BrickType.explosive, BrickSize.size140x220) => {
        BrickDamage.none: 'elementExplosive021.png',
        BrickDamage.some: 'elementExplosive026.png',
        BrickDamage.lots: 'elementExplosive056.png',
      },
    (BrickType.glass, BrickSize.size140x220) => {
        BrickDamage.none: 'elementGlass022.png',
        BrickDamage.some: 'elementGlass027.png',
        BrickDamage.lots: 'elementGlass054.png',
      },
    (BrickType.metal, BrickSize.size140x220) => {
        BrickDamage.none: 'elementMetal021.png',
        BrickDamage.some: 'elementMetal026.png',
        BrickDamage.lots: 'elementMetal056.png',
      },
    (BrickType.stone, BrickSize.size140x220) => {
        BrickDamage.none: 'elementStone021.png',
        BrickDamage.some: 'elementStone026.png',
        BrickDamage.lots: 'elementStone053.png',
      },
    (BrickType.wood, BrickSize.size140x220) => {
        BrickDamage.none: 'elementWood020.png',
        BrickDamage.some: 'elementWood025.png',
        BrickDamage.lots: 'elementWood052.png',
      },
  };
}

class Brick extends BodyComponentWithUserData {
  Brick({
    required this.type,
    required this.size,
    required BrickDamage damage,
    required Vector2 position,
    required Map<BrickDamage, Sprite> sprites,
  })  : _damage = damage,
        _sprites = sprites,
        super(
            renderBody: false,
            bodyDef: BodyDef()
              ..position = position
              ..type = BodyType.dynamic,
            fixtureDefs: [
              FixtureDef(
                PolygonShape()
                  ..setAsBoxXY(
                    size.size.width / 20 * brickScale,
                    size.size.height / 20 * brickScale,
                  ),
              )
                ..restitution = 0.4
                ..density = type.density
                ..friction = type.friction
            ]);

  late final SpriteComponent _spriteComponent;

  final BrickType type;
  final BrickSize size;
  final Map<BrickDamage, Sprite> _sprites;

  BrickDamage _damage;
  BrickDamage get damage => _damage;
  set damage(BrickDamage value) {
    _damage = value;
    _spriteComponent.sprite = _sprites[value];
  }

  @override
  Future<void> onLoad() {
    _spriteComponent = SpriteComponent(
      anchor: Anchor.center,
      scale: Vector2.all(1),
      sprite: _sprites[_damage],
      size: size.size.toVector2() / 10 * brickScale,
      position: Vector2(0, 0),
    );
    add(_spriteComponent);
    return super.onLoad();
  }
}

```

lib\components\enemy.dart

```dart
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'body_component_with_user_data.dart';

const enemySize = 5.0;

enum EnemyColor {
  pink(color: 'pink', boss: false),
  blue(color: 'blue', boss: false),
  green(color: 'green', boss: false),
  yellow(color: 'yellow', boss: false),
  pinkBoss(color: 'pink', boss: true),
  blueBoss(color: 'blue', boss: true),
  greenBoss(color: 'green', boss: true),
  yellowBoss(color: 'yellow', boss: true);

  final bool boss;
  final String color;

  const EnemyColor({required this.color, required this.boss});

  static EnemyColor get randomColor =>
      EnemyColor.values[Random().nextInt(EnemyColor.values.length)];

  String get fileName =>
      'alien${color.capitalize}_${boss ? 'suit' : 'square'}.png';
}

class Enemy extends BodyComponentWithUserData with ContactCallbacks {
  Enemy(Vector2 position, Sprite sprite)
      : super(
          renderBody: false,
          bodyDef: BodyDef()
            ..position = position
            ..type = BodyType.dynamic,
          fixtureDefs: [
            FixtureDef(
              PolygonShape()..setAsBoxXY(enemySize / 2, enemySize / 2),
              friction: 0.3,
            )
          ],
          children: [
            SpriteComponent(
              anchor: Anchor.center,
              sprite: sprite,
              size: Vector2.all(enemySize),
              position: Vector2(0, 0),
            ),
          ],
        );

  @override
  void beginContact(Object other, Contact contact) {
    var interceptVelocity =
        (contact.bodyA.linearVelocity - contact.bodyB.linearVelocity)
            .length
            .abs();
    print("Contact on Enemy made with value of ${interceptVelocity}");
    if (interceptVelocity > 50) {
      removeFromParent();
    }

    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void jump(double verticalVelocity, double horizontalVelocity) {
    body.linearVelocity = Vector2(horizontalVelocity, verticalVelocity);
  }
}

extension on String {
  String get capitalize =>
      characters.first.toUpperCase() + characters.skip(1).toLowerCase().join();
}

```

lib\components\game.dart

```dart
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import 'background.dart';
import 'brick.dart';
import 'enemy.dart';
import 'ground.dart';
import 'player.dart';

class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame({required double screenWidth, required double screenHeight})
      : super(
          gravity: Vector2(0, 10),
        ) {
    // Initialize camera with fixed resolution
    camera = CameraComponent.withFixedResolution(
      width: screenWidth,
      height: screenHeight,
    );
    // Add camera to the game
    add(camera);

    // Set up the timer to make a random enemy jump every 2 seconds
    _jumpTimer = Timer(1.0, repeat: true, onTick: _makeRandomEnemyJump)
      ..start();
  }

  late final XmlSpriteSheet aliens;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet tiles;
  Player? player;

  late final Timer _jumpTimer;

  // Define the desired ground width in terms of tiles
  int groundTileCount = 200;
  double groundWidth = groundSize * 200;

  @override
  FutureOr<void> onLoad() async {
    await _loadAssets();
    await _initializeGame();
    // Set the zoom level after initializing the game
    camera.viewfinder.zoom = 5.0; // Set the desired zoom level here
    return super.onLoad();
  }

  Future<void> _loadAssets() async {
    // Load images and XML sprite sheets only once
    final [backgroundImage, aliensImage, elementsImage, tilesImage] = await [
      images.load('colored_grass.png'),
      images.load('spritesheet_aliens.png'),
      images.load('spritesheet_elements.png'),
      images.load('spritesheet_tiles.png'),
    ].wait;

    aliens = XmlSpriteSheet(aliensImage,
        await rootBundle.loadString('assets/spritesheet_aliens.xml'));
    elements = XmlSpriteSheet(elementsImage,
        await rootBundle.loadString('assets/spritesheet_elements.xml'));
    tiles = XmlSpriteSheet(tilesImage,
        await rootBundle.loadString('assets/spritesheet_tiles.xml'));

    // Initialize the background sprite
    _backgroundSprite = Sprite(backgroundImage);
  }

  late final Sprite _backgroundSprite;

  Future<void> _initializeGame() async {
    // Clear any existing components
    world.children.clear();

    // Add background
    await addBackground();

    // Add ground
    await addGround();

    // Add bricks and enemies
    unawaited(addBricks().then((_) => addEnemies()));

    // Add player
    await addPlayer();

    // Set the camera to follow the player
    if (player != null) {
      camera.follow(player!);
    }
  }

  Future<void> addBackground() async {
    await world.add(Background(
      sprite: _backgroundSprite,
      repeatX: 5, // Repeat the background 5 times
      repeatY: 5,
      offsetX: -250,
      offsetY: 0, // Start the background 50 pixels to the left
    ));
  }

  Future<void> addGround() {
    double tileWidth = groundSize;
    double overlap = 1.0; // Overlap each tile by 1 pixel

    //Example Fixed Y Coordinate for the ground
    double groundY = 100.0; //Example: Place the ground at y=100
    return world.addAll([
      for (var i = 0; i < groundTileCount; i++)
        Ground(
          //Calculate each tile's x position
          Vector2(i * (tileWidth - overlap), groundY),
          tiles.getSprite('grass.png'),
        ),
    ]);
  }

  final _random = Random();

  Future<void> addBricks() async {
    for (var i = 0; i < 15; i++) {
      final type = BrickType.randomType;
      final size = BrickSize.randomSize;
      //Example Coordinates for Bricks
      double brickX = 50.0 + i * 20.0; // Adjust as needed
      double brickY = 20.0; // Adjust as needed
      await world.add(
        Brick(
          type: type,
          size: size,
          damage: BrickDamage.some,
          //Use fixed coordinates
          position: Vector2(brickX, brickY),
          sprites: brickFileNames(type, size).map(
            (key, filename) => MapEntry(
              key,
              elements.getSprite(filename),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> addPlayer() async {
    player = Player(
      Vector2(190, 90),
      aliens.getSprite(PlayerColor.randomColor.fileName),
    );
    await world.add(player!);
  }

  @override
  void update(double dt) {
    super.update(dt * 2); // Double the delta time for all updates
    _jumpTimer.update(dt * 2); // Update the jump timer with double speed

    if (isMounted &&
        world.children.whereType<Player>().isEmpty &&
        world.children.whereType<Enemy>().isNotEmpty) {
      addPlayer();
      if (player != null) {
        camera.follow(player!);
      }
    }
    if (isMounted &&
        enemiesFullyAdded &&
        world.children.whereType<Enemy>().isEmpty &&
        world.children.whereType<FollowingTextComponent>().isEmpty) {
      world.add(
        FollowingTextComponent(
          camera: camera,
          text: 'You Win!',
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );

      // Restart the game after 5 seconds
      Future<void>.delayed(const Duration(seconds: 5), () {
        restart();
      });
    }
  }

  var enemiesFullyAdded = false;

  Future<void> addEnemies() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    for (var i = 0; i < 11; i++) {
      // Example Coordinates for Enemies
      double enemyX = 80.0 + i * 30.0; // Adjust as needed
      double enemyY = 10.0; // Adjust as needed
      await world.add(
        Enemy(
          // Use fixed coordinates
          Vector2(enemyX, enemyY),
          aliens.getSprite(EnemyColor.randomColor.fileName),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    enemiesFullyAdded = true;
  }

  void restart() async {
    // Reset game-specific state variables
    enemiesFullyAdded = false;

    // Properly remove all components from the world
    for (var component in List<Component>.from(world.children)) {
      world.remove(component);
    }

    // Ensure all components are removed before reinitializing
    await Future.delayed(const Duration(milliseconds: 100));

    // Reload the game
    await _initializeGame();
  }

  void _makeRandomEnemyJump() {
    final enemies = world.children.whereType<Enemy>().toList();
    if (enemies.isNotEmpty) {
      final randomEnemy = enemies[_random.nextInt(enemies.length)];
      // Randomly decide between 10.0 and -10.0
      final randomVelocity = _random.nextBool() ? 10.0 : -10.0;
      randomEnemy.jump(-20.0, randomVelocity); // Example jump velocities
    }
  }
}

class XmlSpriteSheet {
  XmlSpriteSheet(this.image, String xml) {
    final document = XmlDocument.parse(xml);
    for (final node in document.xpath('//TextureAtlas/SubTexture')) {
      final name = node.getAttribute('name')!;
      final x = double.parse(node.getAttribute('x')!);
      final y = double.parse(node.getAttribute('y')!);
      final width = double.parse(node.getAttribute('width')!);
      final height = double.parse(node.getAttribute('height')!);
      _rects[name] = Rect.fromLTWH(x, y, width, height);
    }
  }

  final ui.Image image;
  final _rects = <String, Rect>{};

  Sprite getSprite(String name) {
    final rect = _rects[name];
    if (rect == null) {
      throw ArgumentError('Sprite $name not found');
    }
    return Sprite(
      image,
      srcPosition: rect.topLeft.toVector2(),
      srcSize: rect.size.toVector2(),
    );
  }
}

class FollowingTextComponent extends TextComponent {
  FollowingTextComponent({
    required this.camera,
    required super.text,
    required super.textRenderer,
    super.anchor,
    super.priority,
    super.children,
  });

  final CameraComponent camera;

  @override
  void update(double dt) {
    super.update(dt);
    // Update the position based on the camera's position
    position = camera.getCameraPosition();
  }
}

```

lib\components\ground.dart

```dart
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'body_component_with_user_data.dart'; // Add this import

const groundSize = 7.0;

class Ground extends BodyComponentWithUserData {
  // Edit this line
  Ground(Vector2 position, Sprite sprite)
      : super(
          renderBody: false,
          bodyDef: BodyDef()
            ..position = position
            ..type = BodyType.static,
          fixtureDefs: [
            FixtureDef(
              PolygonShape()..setAsBoxXY(groundSize / 2, groundSize / 2),
              friction: 0.3,
            )
          ],
          children: [
            SpriteComponent(
              anchor: Anchor.center,
              sprite: sprite,
              size: Vector2.all(groundSize),
              position: Vector2(0, 0),
            ),
          ],
        );
}

```

lib\components\player.dart

```dart
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'body_component_with_user_data.dart';

const playerSize = 5.0;

// Enums are efficient for representing a fixed set of values, no changes needed
enum PlayerColor {
  pink,
  blue,
  green,
  yellow;

  static PlayerColor get randomColor =>
      PlayerColor.values[Random().nextInt(PlayerColor.values.length)];

  String get fileName =>
      'alien${toString().split('.').last.capitalize}_round.png';
}

class Player extends BodyComponentWithUserData
    with DragCallbacks, ContactCallbacks {
  Player(Vector2 position, Sprite sprite)
      : _sprite = sprite,
        super(
          renderBody: false,
          bodyDef: BodyDef()
            ..position = position
            ..type = BodyType.static
            ..angularDamping = 0.1
            ..linearDamping = 0.1,
          fixtureDefs: [
            FixtureDef(CircleShape()..radius = playerSize / 2)
              ..restitution = 0.4
              ..density = 0.75
              ..friction = 0.5
          ],
        );

  final Sprite _sprite;

  @override
  Future<void> onLoad() {
    // Component creation is efficient, no changes needed
    addAll([
      CustomPainterComponent(
        painter: _DragPainter(this),
        anchor: Anchor.center,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      ),
      SpriteComponent(
        anchor: Anchor.center,
        sprite: _sprite,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      )
    ]);
    return super.onLoad();
  }

  @override
  update(double dt) {
    super.update(dt);

    // Cache visibleWorldRect for performance
    var visibleRect = camera.visibleWorldRect;

    if (!body.isAwake) {
      removeFromParent();
    }

    if (position.x > visibleRect.right + 10 ||
        position.x < visibleRect.left - 10) {
      removeFromParent();
    }
  }

  Vector2 _dragStart = Vector2.zero();
  Vector2 _dragDelta = Vector2.zero();
  Vector2 get dragDelta => _dragDelta;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (body.bodyType == BodyType.static) {
      _dragStart = event.localPosition;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (body.bodyType == BodyType.static) {
      _dragDelta = event.localEndPosition - _dragStart;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (body.bodyType == BodyType.static) {
      // Finding the first child of a specific type is generally efficient
      // but could be optimized further if there are many children.
      children
          .whereType<CustomPainterComponent>()
          .firstOrNull
          ?.removeFromParent();
      body.setType(BodyType.dynamic);
      body.applyLinearImpulse(_dragDelta * -50);
      add(RemoveEffect(
        delay: 5.0,
      ));
    }
  }
}

// String extension is efficient, no changes needed
extension on String {
  String get capitalize =>
      characters.first.toUpperCase() + characters.skip(1).toLowerCase().join();
}

class _DragPainter extends CustomPainter {
  _DragPainter(this.player);

  final Player player;

  @override
  void paint(Canvas canvas, Size size) {
    // Vector and canvas operations are generally efficient, no changes needed
    if (player.dragDelta != Vector2.zero()) {
      var center = size.center(Offset.zero);
      canvas.drawLine(
          center,
          center + (player.dragDelta * -1).toOffset(),
          Paint()
            ..color = Colors.orange.withOpacity(0.7)
            ..strokeWidth = 0.4
            ..strokeCap = StrokeCap.round);
    }
  }

  // No need to check for changes in this simple painter,
  // so we can return false for shouldRepaint.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

```

lib\main.dart

```dart
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

```

