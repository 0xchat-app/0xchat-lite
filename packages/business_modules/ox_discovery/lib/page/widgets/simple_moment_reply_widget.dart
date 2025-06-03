import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat_ui/ox_chat_ui.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_discovery/model/moment_ui_model.dart';
import 'package:ox_discovery/utils/album_utils.dart';
import 'package:ox_localizable/ox_localizable.dart';
import '../../utils/moment_content_analyze_utils.dart';
import '../../utils/moment_widgets_utils.dart';

import 'package:nostr_core_dart/nostr.dart';

class SimpleMomentReplyWidget extends StatefulWidget {
  final NotedUIModel? notedUIModel;
  final Function? postNotedCallback;
  final Function(bool isFocused)? isFocusedCallback;
  const SimpleMomentReplyWidget(
      {super.key, this.isFocusedCallback, required this.notedUIModel,this.postNotedCallback});

  @override
  _SimpleMomentReplyWidgetState createState() =>
      _SimpleMomentReplyWidgetState();
}

class _SimpleMomentReplyWidgetState extends State<SimpleMomentReplyWidget> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  bool _isFocused = false;
  String? imageUrl;
  bool isShowEmoji = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _replyFocusNode.addListener(() {
      widget.isFocusedCallback?.call(_replyFocusNode.hasFocus);
      if (!_replyFocusNode.hasFocus) {
        isShowEmoji = false;
      }
      setState(() {
        _isFocused = _replyFocusNode.hasFocus;
      });
    });

    _getMomentUserInfo();
  }

  void _getMomentUserInfo()async {
    String? pubKey = widget.notedUIModel?.noteDB.author;
    if(pubKey == null) return;
    await Account.sharedInstance.getUserInfo(pubKey);
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.px),
      padding: EdgeInsets.all(12.px),
      decoration: BoxDecoration(
        color: ThemeColor.color190,
        borderRadius: BorderRadius.all(
          Radius.circular(
            12.px,
          ),
        ),
      ),
      child: Column(
        children: [
          _postYourReplyHeadWidget(),
          _postYourReplyContentWidget(),
          _buildEmojiDialog(),
        ],
      ),
    );
  }

  Widget _postYourReplyHeadWidget() {
    String? pubKey = widget.notedUIModel?.noteDB.author;
    if (!_isFocused || pubKey == null) return const SizedBox();
    return Container(
      padding: EdgeInsets.only(
        bottom: 8.px,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder<UserDBISAR>(
            valueListenable: Account.sharedInstance.getUserNotifier(pubKey),
            builder: (context, value, child) {
              return RichText(
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.px,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: Localized.text('ox_discovery.reply_destination_title'),
                      style: TextStyle(
                        color: ThemeColor.color120,
                      ),
                    ),
                    TextSpan(
                      text: '@${value.name ?? ''}',
                      style: TextStyle(
                        color: ThemeColor.gradientMainStart,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            children: [
              _mediaWidget(),
              GestureDetector(
                onTap: _postMoment,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.px,
                    vertical: 2.px,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ThemeColor.color180,
                      borderRadius: BorderRadius.circular(4.px),
                      gradient: LinearGradient(
                        colors: [
                          ThemeColor.gradientMainEnd,
                          ThemeColor.gradientMainStart,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )),
                  child: Text(
                    Localized.text('ox_discovery.post'),
                    style: TextStyle(
                      fontSize: Adapt.px(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postYourReplyContentWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.px,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.color180,
        borderRadius: BorderRadius.all(
          Radius.circular(
            12.px,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _showImageWidget(),
          TextField(
            controller: _replyController,
            focusNode: _replyFocusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: Localized.text('ox_discovery.post_reply'),
              hintStyle: TextStyle(
                color: ThemeColor.color120,
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          )
        ],
      ),
    );
  }

  Widget _showImageWidget() {
    if (imageUrl == null) return const SizedBox();
    return MomentWidgetsUtils.clipImage(
      borderRadius: 8.px,
      child: Image.asset(
        imageUrl!,
        width: 100.px,
        fit: BoxFit.fill,
        height: 100.px,
      ),
    ).setPaddingOnly(top: 12.px);
  }

  Widget _mediaWidget() {
    return Container(
      margin: EdgeInsets.only(
        right: 12.px,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              AlbumUtils.openAlbum(context, type: 1, selectCount: 1,
                  callback: (List<String> imageList) {
                imageUrl = imageList[0];
                setState(() {});
              });
            },
            child: CommonImage(
              iconName: 'chat_image_icon.png',
              size: 24.px,
              package: 'ox_discovery',
            ),
          ),
          // SizedBox(
          //   width: 12.px,
          // ),
          // GestureDetector(
          //   onTap: () {
          //     setState(() {
          //       isShowEmoji = !isShowEmoji;
          //     });
          //   },
          //   child: CommonImage(
          //     iconName: 'chat_emoti_icon.png',
          //     size: 24.px,
          //     package: 'ox_discovery',
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildEmojiDialog() {
    if (!isShowEmoji) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.px),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(12)),
        color: ThemeColor.color190,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 180.px,
          child: InputFacePage(
            textController: _replyController,
          ),
        ),
      ),
    );
  }

  void _postMoment() async {
    if(widget.notedUIModel == null) return;
    if (_replyController.text.isEmpty && imageUrl == null) {
      CommonToast.instance.show(context, Localized.text('ox_discovery.content_empty_tips'));
      return;
    }
    await OXLoading.show();
    String getMediaStr = await _getUploadMediaContent();
    String content = '${_replyController.text} $getMediaStr';
    List<String> hashTags = MomentContentAnalyzeUtils(content).getMomentHashTagList;
    OKEvent event = await Moment.sharedInstance.sendReply(widget.notedUIModel!.noteDB.noteId, content,hashTags:hashTags);
    await OXLoading.dismiss();

    if (event.status) {
      widget.postNotedCallback?.call();
      _replyController.text = '';
      _replyFocusNode.unfocus();
      widget.isFocusedCallback?.call(false);

      CommonToast.instance.show(context, Localized.text('ox_discovery.reply_success_tips'));
    }
  }

  Future<String> _getUploadMediaContent() async {
    String? imagePath = imageUrl;
    if (imagePath == null) return '';
    List<String> imageList = [imagePath];

    if (imageList.isNotEmpty) {
      List<String> imgUrlList = await AlbumUtils.uploadMultipleFiles(
        context,
        fileType: FileType.image,
        filePathList: imageList,
      );
      String getImageUrlToStr = imgUrlList.join(' ');
      return getImageUrlToStr;
    }

    return '';
  }
}
