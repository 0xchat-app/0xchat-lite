
import 'package:chatcore/chat-core.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat/widget/common_chat_nav_bar.dart';
import 'package:ox_chat/widget/common_chat_widget.dart';
import 'package:ox_chat_ui/ox_chat_ui.dart';
import 'package:ox_chat/utils/general_handler/chat_general_handler.dart';
import 'package:ox_chat/utils/chat_log_utils.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';

class ChatGroupMessagePage extends StatefulWidget {

  final ChatGeneralHandler handler;

  const ChatGroupMessagePage({
    super.key,
    required this.handler,
  });

  @override
  State<ChatGroupMessagePage> createState() => _ChatGroupMessagePageState();
}

class _ChatGroupMessagePageState extends State<ChatGroupMessagePage> {

  GroupDBISAR? group;
  ChatGeneralHandler get handler => widget.handler;
  ChatSessionModelISAR get session => handler.session;
  String get groupId => group?.groupId ?? session.groupId ?? '';

  ChatHintParam? bottomHintParam;

  @override
  void initState() {
    setupGroup();
    super.initState();

    prepareData();
  }

  void setupGroup() {
    final groupId = session.groupId;
    if (groupId == null) return ;
    group = Groups.sharedInstance.groups[groupId]?.value;
  }

  void prepareData() {
    _updateChatStatus();
  }

  @override
  Widget build(BuildContext context) {
    return CommonChatWidget(
      handler: handler,
      navBar: buildNavBar(),
      bottomHintParam: bottomHintParam,
    );
  }

  CLAppBar buildNavBar() {
    GroupDBISAR? group = Groups.sharedInstance.groups[groupId]?.value;
    String showName = group?.name ?? '';
    return CLAppBar(
      title: showName,
      actions: [
        Container(
          alignment: Alignment.center,
          child: OXGroupAvatar(
            group: group,
            size: 36,
            isClickable: true,
            onReturnFromNextPage: () {
              if (!mounted) return ;
              setState(() { });
            },
          ),
        ),
      ],
    );
    // return CommonChatNavBar(
    //   handler: handler,
    //   title: showName,
    //   actions: [
    //     Container(
    //       alignment: Alignment.center,
    //       child: OXGroupAvatar(
    //         group: group,
    //         size: 36,
    //         isClickable: true,
    //         onReturnFromNextPage: () {
    //           if (!mounted) return ;
    //           setState(() { });
    //         },
    //       ),
    //     ),
    //   ],
    // );
  }

  void _updateChatStatus() {
    if (!Groups.sharedInstance.checkInGroup(groupId)) {
      bottomHintParam = ChatHintParam(
        Localized.text('ox_chat_ui.group_request'),
        onRequestGroupTap,
      );
      return ;
    } else if (!Groups.sharedInstance.checkInMyGroupList(groupId)) {
      bottomHintParam = ChatHintParam(
        Localized.text('ox_chat_ui.group_join'),
        onJoinGroupTap,
      );
      return ;
    }

    final userDB = OXUserInfoManager.sharedInstance.currentUserInfo;

    if (groupId.isEmpty || userDB == null) {
      ChatLogUtils.error(
        className: 'ChatGroupMessagePage',
        funcName: '_initializeChatStatus',
        message: 'groupId: $groupId, userDB: $userDB',
      );
      return ;
    }

    bottomHintParam = null;
  }

  Future onJoinGroupTap() async {
    await OXLoading.show();
    final OKEvent okEvent = await Groups.sharedInstance.joinGroup(groupId, '${handler.author.firstName} join the group');
    await OXLoading.dismiss();
    if (okEvent.status) {
      OXChatBinding.sharedInstance.groupsUpdatedCallBack();
      setState(() {
        _updateChatStatus();
      });
    } else {
      CommonToast.instance.show(context, okEvent.message);
    }
  }

  Future onRequestGroupTap() async {
    OXModuleService.invoke('ox_chat', 'groupSharePage',[context],
        {
          Symbol('groupPic'): group?.picture ?? '',
          Symbol('groupName'):groupId,
          Symbol('groupOwner'): group?.owner ?? '',
          Symbol('groupId'):groupId,
          Symbol('inviterPubKey'):'',
        }
    );
    // await OXLoading.show();
    // final OKEvent okEvent = await Groups.sharedInstance.requestGroup(groupId, group?.owner ?? '','');
    //
    // await OXLoading.dismiss();
    // if (okEvent.status) {
    //   CommonToast.instance.show(context, 'Request Sent!');
    // } else {
    //   CommonToast.instance.show(context, okEvent.message);
    // }
  }
}
