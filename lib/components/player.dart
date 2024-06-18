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
