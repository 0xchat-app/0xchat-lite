import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/common_image.dart';

class GiphySearchBar extends StatefulWidget {

  final bool? enable;

  final ValueChanged<String>? onSubmitted;

  final GestureTapCallback? onTap;

  final String? hintText;

  const GiphySearchBar({super.key,this.enable,this.onSubmitted,this.onTap,this.hintText});

  @override
  State<GiphySearchBar> createState() => _GiphySearchBarState();
}

class _GiphySearchBarState extends State<GiphySearchBar> {

  bool _isClear = false;

  late TextEditingController _controller;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _controller = TextEditingController();
    // _focusNode.requestFocus();
    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        _isClear = true;
      } else {
        _isClear = false;
      }
      setState(() {
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ThemeColor.color180,
          ),
          height: Adapt.px(38),
          padding: EdgeInsets.symmetric(horizontal: Adapt.px(12)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enable,
                  textInputAction: TextInputAction.search,
                  onSubmitted: widget.onSubmitted,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    icon: Container(
                      child: CommonImage(
                        iconName: 'icon_search.png',
                        width: Adapt.px(24),
                        height: Adapt.px(24),
                        fit: BoxFit.fill,
                      ),
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: Adapt.px(14),
                      fontWeight: FontWeight.w400,
                      height: Adapt.px(22) / Adapt.px(14),
                      color: ThemeColor.color100
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: Adapt.px(13))
                  ),
                ),
              ),
              _isClear
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                      },
                      child: CommonImage(
                        iconName: 'icon_textfield_close.png',
                        width: Adapt.px(16),
                        height: Adapt.px(16),
                      ),
                    )
                  : Container(),
            ],
          )),
    );
    ;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
