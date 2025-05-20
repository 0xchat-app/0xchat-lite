

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/widgets/common_image.dart';

import 'button/elevated_button.dart';
import 'button/filled_button.dart';
import 'button/icon_button.dart';
import 'button/outlined_button.dart';
import 'button/text_button.dart';
import 'button/tonal_button.dart';
import 'color_token.dart';
import 'text.dart';

class CLButton {
  static Widget _defaultText(String text) {
    return CLText(text, customColor: null);
  }

  /// Wraps the inner label with optional [alignment] while keeping the label‑
  /// driven size (using width/heightFactor = 1).
  static Widget _alignIfNeeded(Widget child, AlignmentGeometry? alignment) {
    if (alignment == null) return child;
    return Align(
      alignment: alignment,
      widthFactor: 1,
      heightFactor: 1,
      child: child,
    );
  }

  /// Applies fixed size or expands to fill according to [expanded], [width],
  /// and [height].
  static Widget _sizeWrapper(
    Widget button, {
    bool expanded = false,
    double? width,
    double? height,
  }) {
    if (expanded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double? w = constraints.maxWidth.isFinite
              ? constraints.maxWidth : null;
          final double? h = constraints.maxHeight.isFinite
              ? constraints.maxHeight : null;
          return SizedBox(width: w, height: h, child: button);
        },
      );
    }
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    return button;
  }

  static Widget filled({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    return _sizeWrapper(
      CLFilledButton(onTap: onTap, child: child),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget tonal({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    return _sizeWrapper(
      CLTonalButton(onTap: onTap, child: child),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget elevated({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    return _sizeWrapper(
      CLElevatedButton(onTap: onTap, child: child),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget outlined({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    return _sizeWrapper(
      CLOutlinedButton(onTap: onTap, child: child),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget text({
    String? text,
    AlignmentGeometry? alignment,
    Widget? child,
    VoidCallback? onTap,
    bool expanded = false,
    double? width,
    double? height,
  }) {
    child ??= _defaultText(text ?? '');
    child = _alignIfNeeded(child, alignment);

    return _sizeWrapper(
      CLTextButton(onTap: onTap, child: child),
      expanded: expanded,
      width: width,
      height: height,
    );
  }

  static Widget icon({
    required String iconName,
    required String package,
    Widget? child,
    VoidCallback? onTap,
    double? size,
    EdgeInsets? padding,
  }) {
    // Default: 44 size & 20 padding
    padding ??= size == null ? EdgeInsets.all(20) : null;
    child ??= CommonImage(
      iconName: iconName,
      size: size ?? 24,
      color: ColorToken.primary.of(OXNavigator.navigatorKey.currentContext!),
      package: package,
    );

    return CLIconButton(
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }
}