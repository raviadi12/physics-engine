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
