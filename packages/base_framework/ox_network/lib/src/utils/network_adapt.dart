import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io' show Platform;

class NetAdapt {
  static MediaQueryData? mediaQuery;
  static double? _width;
  static double? _height;
  static double? _topbarH;
  static double? _botbarH;
  static double? _pixelRatio;
  static num statusBarHeight = 0.0;
  static double? _ratioW;
  static var _ratioH;
  static double? _textScaleFactor;

  static init({int standardW = 0, int standardH = 0}) {
    mediaQuery = MediaQueryData.fromView(window);
    _width = mediaQuery?.size.width;
    _height = mediaQuery?.size.height;
    _topbarH = mediaQuery?.padding.top;
    _botbarH = mediaQuery?.padding.bottom;
    _pixelRatio = mediaQuery?.devicePixelRatio;
    _textScaleFactor = mediaQuery?.textScaleFactor;

    int uiwidth = standardW is int ? standardW : 375;
    if (_width != null) {
      _ratioW = _width! / uiwidth;
    }

    int uiheight = standardH is int ? standardH : 812;
    if (_height != null) {
      _ratioH = _height! / uiheight;
    }
  }

  static px(number) {
    if (!(_ratioW is double || _ratioW is int)) {
      NetAdapt.init(standardW: 375, standardH: 812);
    }
    return number * _ratioW;
  }

  static sp(number, {bool allowFontScaling = false}) {
    return allowFontScaling ? px(number) : px(number) / _textScaleFactor;
  }

  static py(number) {
    if (!(_ratioH is double || _ratioH is int)) {
      NetAdapt.init(standardW: 375, standardH: 812);
    }
    return number * _ratioH;
  }

  static onepx() {
    if (_pixelRatio == null) {
      return 0;
    }
    return 1 / _pixelRatio!;
  }

  static screenW() {
    return _width;
  }

  static screenH() {
    return _height;
  }

  static padTopH() {
    return Platform.isAndroid ? statusBarHeight + 0.0 : _topbarH;
  }

  static padBotH() {
    return _botbarH;
  }
}
