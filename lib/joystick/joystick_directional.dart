import 'dart:math';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class JoystickDirectional {
  final double size;
  final Sprite spriteBackgroundDirectional;
  final Sprite spriteKnobDirectional;
  final bool isFixed;
  final EdgeInsets margin;
  final Color color;

  Paint _paintBackground;
  Paint _paintKnob;

  double _backgroundAspectRatio = 2.2;
  Rect _backgroundRect;
  Sprite _backgroundSprite;

  Rect _knobRect;
  Sprite _knobSprite;

  bool _dragging = false;

  Offset _dragPosition;

  double _tileSize;

  int _pointerDragging = 0;

  JoystickListener _joystickListener;

  Size _screenSize;

  JoystickDirectional({
    this.spriteBackgroundDirectional,
    this.spriteKnobDirectional,
    this.isFixed = true,
    this.margin = const EdgeInsets.only(left: 100, bottom: 100),
    this.size = 80,
    this.color = Colors.blueGrey,
  }) {
    if (spriteBackgroundDirectional != null) {
      _backgroundSprite = spriteBackgroundDirectional;
    } else {
      _paintBackground = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
    }
    if (spriteKnobDirectional != null) {
      _knobSprite = spriteKnobDirectional;
    } else {
      _paintKnob = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
    }

    _tileSize = size / 2;
  }

  void initialize(Size _screenSize, JoystickListener joystickListener) {
    this._screenSize = _screenSize;
    _joystickListener = joystickListener;
    Offset osBackground =
        Offset(margin.left, _screenSize.height - margin.bottom);
    _backgroundRect = Rect.fromCircle(center: osBackground, radius: size / 2);

    Offset osKnob =
        Offset(_backgroundRect.center.dx, _backgroundRect.center.dy);
    _knobRect = Rect.fromCircle(center: osKnob, radius: size / 4);

    _dragPosition = _knobRect.center;
  }

  void render(Canvas canvas) {
    if (_backgroundRect != null) {
      if (_backgroundSprite != null) {
        _backgroundSprite.renderRect(canvas, _backgroundRect);
      } else {
        double radiusBackground = _backgroundRect.width / 2;
        canvas.drawCircle(
          Offset(_backgroundRect.left + radiusBackground,
              _backgroundRect.top + radiusBackground),
          radiusBackground,
          _paintBackground,
        );
      }
    }

    if (_knobRect != null) {
      if (_knobSprite != null) {
        _knobSprite.renderRect(canvas, _knobRect);
      } else {
        double radiusKnob = _knobRect.width / 2;
        canvas.drawCircle(
          Offset(_knobRect.left + radiusKnob, _knobRect.top + radiusKnob),
          radiusKnob,
          _paintKnob,
        );
      }
    }
  }

  void update(double t) {
    if (_dragging) {
      double _radAngle = atan2(_dragPosition.dy - _backgroundRect.center.dy,
          _dragPosition.dx - _backgroundRect.center.dx);

      double degrees = _radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      Point p = Point(_backgroundRect.center.dx, _backgroundRect.center.dy);
      double dist = p.distanceTo(Point(_dragPosition.dx, _dragPosition.dy));

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = dist < (_tileSize * _backgroundAspectRatio / 3)
          ? dist
          : (_tileSize * _backgroundAspectRatio / 3);

      // Calculation the knob position
      double nextX = dist * cos(_radAngle);
      double nextY = dist * sin(_radAngle);
      Offset nextPoint = Offset(nextX, nextY);

      Offset diff = Offset(_backgroundRect.center.dx + nextPoint.dx,
              _backgroundRect.center.dy + nextPoint.dy) -
          _knobRect.center;
      _knobRect = _knobRect.shift(diff);

      double _intensity = dist / (_tileSize * _backgroundAspectRatio / 3);

      if (degrees > -22.5 && degrees <= 22.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 22.5 && degrees <= 67.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 67.5 && degrees <= 112.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 112.5 && degrees <= 157.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if ((degrees > 157.5 && degrees <= 180) ||
          (degrees >= -180 && degrees <= -157.5)) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -157.5 && degrees <= -112.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -112.5 && degrees <= -67.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -67.5 && degrees <= -22.5) {
        _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }
    } else {
      if (_knobRect != null) {
        Offset diff = _dragPosition - _knobRect.center;
        _knobRect = _knobRect.shift(diff);
      }
    }
  }

  void directionalDown(int pointer, Offset localPosition) {
    if (_backgroundRect == null) return;

    _updateDirectionalRect(localPosition);

    Rect directional = Rect.fromLTWH(
      _backgroundRect.left - 50,
      _backgroundRect.top - 50,
      _backgroundRect.width + 100,
      _backgroundRect.height + 100,
    );
    if (!_dragging && directional.contains(localPosition)) {
      _dragging = true;
      _dragPosition = localPosition;
      _pointerDragging = pointer;
    }
  }

  void directionalMove(int pointer, Offset localPosition) {
    if (pointer == _pointerDragging) {
      if (_dragging) {
        _dragPosition = localPosition;
      }
    }
  }

  void directionalUp(int pointer) {
    if (pointer == _pointerDragging) {
      _dragging = false;
      _dragPosition = _backgroundRect.center;
      _joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.IDLE,
        intensity: 0.0,
        radAngle: 0.0,
      ));
    }
  }

  void _updateDirectionalRect(Offset position) {
    if (_screenSize != null &&
        (position.dx > _screenSize.width / 3 ||
            position.dy < _screenSize.height / 3 ||
            isFixed)) return;

    _backgroundRect = Rect.fromCircle(center: position, radius: size / 2);

    Offset osKnob =
        Offset(_backgroundRect.center.dx, _backgroundRect.center.dy);
    _knobRect = Rect.fromCircle(center: osKnob, radius: size / 4);
  }
}
