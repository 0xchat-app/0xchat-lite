
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/font_size_notifier.dart';

class Adapt {
  static MediaQueryData? mediaQuery;
  static double? _width;
  static double? _height;
  static double? _topbarH;
  static double? _botbarH;
  static double? _pixelRatio;
  static double get devicePixelRatio => _pixelRatio ?? 1;
  static num statusBarHeight = 0.0;
  static double? _ratioW;
  static var _ratioH;
  static double _textScaleFactor = 1.0;

  static get isInitialized => _ratioW != null;

  static init() {
    final context = OXNavigator.navigatorKey.currentContext;
    final view = context != null ? View.of(context) : window;

    final standardW = 412;
    final standardH = 917;

    mediaQuery = MediaQueryData.fromView(view);
    _width = mediaQuery?.size.width;
    _height = mediaQuery?.size.height;
    _topbarH = mediaQuery?.padding.top;
    _botbarH = mediaQuery?.padding.bottom;
    _pixelRatio = mediaQuery?.devicePixelRatio;
    _textScaleFactor = mediaQuery?.textScaleFactor ?? _textScaleFactor;

    if (_width != null) {
      if (Platform.isIOS && _width! > 375.0)
        _ratioW = 1;
      else
        _ratioW = _width! / standardW;
    }

    if (_height != null) {
      _ratioH = _height! / standardH;
    }
  }

  static double px(number) {
    final orientation = MediaQuery.of(OXNavigator.navigatorKey.currentContext!).orientation;
    if(PlatformUtils.isDesktop || (Platform.isAndroid && orientation == Orientation.landscape)) {
      return double.tryParse(number.toString()) ?? 0.0;
    }
    if (!(_ratioW is double || _ratioW is int)) {
      Adapt.init();
    }
    return number * _ratioW;
  }

  static double sp(number, {bool allowFontScaling = false}) {
    final fontSize = allowFontScaling ? px(number) * _textScaleFactor : px(number);
    return fontSize.floorToDouble();
  }

  static py(number) {
    if (!(_ratioH is double || _ratioH is int)) {
      Adapt.init();
    }
    return number * _ratioH;
  }

  static onepx() {
    if (_pixelRatio == null) {
      return 0;
    }
    return 1 / _pixelRatio!;
  }

  static double get screenW {
    return _width ?? 0.0;
  }

  static double get screenH {
    return _height ?? 0.0;
  }

  static padTopH() {
    return Platform.isAndroid ? statusBarHeight + 0.0 : _topbarH;
  }

  static padBotH() {
    return _botbarH;
  }

  static double get topSafeAreaHeight {
    final window = WidgetsBinding.instance.window;
    final padding = window.padding;
    return padding.top / window.devicePixelRatio;
  }

  static double get bottomSafeAreaHeightByKeyboard {
    final window = WidgetsBinding.instance.window;
    final viewInsets = window.viewInsets;
    final padding = window.padding;
    return (viewInsets.bottom + padding.bottom) / window.devicePixelRatio;
  }
}

extension AdaptEx on num {
  double get px => Adapt.px(this);
  double get py => Adapt.py(this);
  double get sp => Adapt.sp(this);

  double get pxWithTextScale => textScaleFactorNotifier.value * px;
  double get spWithTextScale => textScaleFactorNotifier.value * sp;
}