import 'package:flutter/material.dart';
import 'package:ox_common/widgets/common_image.dart';

import '../state/inherited_chat_theme.dart';

/// A class that represents attachment button widget.
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget.
  const AttachmentButton({
    super.key,
    this.isLoading = false,
    this.onPressed,
    this.padding = EdgeInsets.zero,
    required this.size,
  });

  /// Show a loading indicator instead of the button.
  final bool isLoading;

  /// Callback for attachment button tap event.
  final VoidCallback? onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        margin: InheritedChatTheme.of(context).theme.attachmentButtonMargin ?? EdgeInsetsDirectional.zero,
        child: CommonIconButton(
          iconName: 'chat_voice_icon.png',
          size: size,
          package: 'ox_chat_ui',
          onPressed: onPressed ?? () {},
          padding: padding,
        ),
      );
}
