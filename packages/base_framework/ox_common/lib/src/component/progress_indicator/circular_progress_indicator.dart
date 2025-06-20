
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_style.dart';
import '../theme_data.dart';

class CLCircularProgressIndicator extends StatelessWidget {
  const CLCircularProgressIndicator({
    super.key,
    this.progress,
    this.size,
  });

  final double? progress;
  final double? size;

  double get defaultSize => 40; // _CircularProgressIndicatorDefaultsM3.constraints

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialIndicator(context);
    } else {
      return _buildCupertinoIndicator(context);
    }
  }

  Widget _buildMaterialIndicator(BuildContext context) {
    final size = this.size ?? defaultSize;
    // _CircularProgressIndicatorDefaultsM3Year2023.strokeWidth = 4.0
    final strokeWidth = 4.0 * size / defaultSize;
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }

  Widget _buildCupertinoIndicator(BuildContext context) {
    final size = this.size ?? defaultSize;
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: progress == null ?
      CupertinoActivityIndicator(radius: size / 2) :
      _buildCircularProgressIndicatorForCupertino(context, size),
    );
  }

  Widget _buildCircularProgressIndicatorForCupertino(BuildContext context, double size) {
    final trackColor = CupertinoTrackColorEx.of(context);
    final strokeWidth = 6.0;
    final halfStroke = strokeWidth / 2;
    final effectivePad = EdgeInsets.all(halfStroke);
    return Container(
      height: size,
      width: size,
      padding: effectivePad,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
        backgroundColor: trackColor,
      ),
    );
  }
}