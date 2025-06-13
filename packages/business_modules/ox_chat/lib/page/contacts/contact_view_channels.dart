import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_common/utils/ox_chat_observer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_chat/widget/contact_channel.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/mixin/common_state_view_mixin.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_pull_refresher.dart';

class ContactViewChannels extends StatefulWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? topWidget;
  ContactViewChannels({Key? key, this.shrinkWrap = false, this.physics, this.topWidget}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ContactViewChannelsState();
  }
}

class _ContactViewChannelsState extends State<ContactViewChannels> with SingleTickerProviderStateMixin,
    AutomaticKeepAliveClientMixin, WidgetsBindingObserver, CommonStateViewMixin, OXChatObserver, OXUserInfoObserver {
  List<ChannelDBISAR> channels = [];
  RefreshController _refreshController = RefreshController();
  GlobalKey<ChannelContactState> channelsWidgetKey = new GlobalKey<ChannelContactState>();
  num imageV = 0;

  @override
  void initState() {
    super.initState();
    OXUserInfoManager.sharedInstance.addObserver(this);
    OXChatBinding.sharedInstance.addObserver(this);
    WidgetsBinding.instance.addObserver(this);
    _onRefresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    OXUserInfoManager.sharedInstance.removeObserver(this);
    OXChatBinding.sharedInstance.removeObserver(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonStateViewWidget(
      context,
      ChannelContact(
        key: channelsWidgetKey,
        data: channels,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        topWidget: widget.topWidget,
      ),
    );
  }

  void _loadData() async {
    Map<String, ValueNotifier<ChannelDBISAR>> channelsMap = Channels.sharedInstance.myChannels;
    channels = channelsMap.values.map((e) => e.value).toList();
    if(Channels.sharedInstance.myChannels.length>0) {
      channels = Channels.sharedInstance.myChannels.values.map((e) => e.value).toList();
    }
    _showView();
  }

  void _showView() {
    if (this.mounted) {
      channelsWidgetKey.currentState?.updateContactData(channels);
      setState(() {
        updateStateView(CommonStateView.CommonStateView_None);
      });
    }
  }

  @override
  stateViewCallBack(CommonStateView commonStateView) {
    switch (commonStateView) {
      case CommonStateView.CommonStateView_None:
        break;
      case CommonStateView.CommonStateView_NetworkError:
      case CommonStateView.CommonStateView_NoData:
        _onRefresh();
        break;
      case CommonStateView.CommonStateView_NotLogin:
        break;
    }
  }

  void _onRefresh() async {
    imageV++;
    bool isLogin = LoginManager.instance.isLoginCircle;
    if (isLogin == false) {
      setState(() {
        updateStateView(CommonStateView.CommonStateView_NotLogin);
      });
    } else {
      setState(() {
        _loadData();
      });
    }
    _refreshController.refreshCompleted();
  }

  @override
  void didLoginSuccess(UserDBISAR? userInfo) {
    LogUtil.e('Topic List didLoginStateChanged : $userInfo');
    setState(() {
      channels.clear();
      _onRefresh();
    });
  }

  @override
  void didLogout() {
    setState(() {
      channels.clear();
      _onRefresh();
    });
  }

  @override
  void didSwitchUser(UserDBISAR? userInfo) {
    _onRefresh();
  }

  @override
  void didCreateChannel(ChannelDBISAR? channelDB) {
    _loadData();
  }

  @override
  void didChannelsUpdatedCallBack() {
    _loadData();
  }



  @override
  void didDeleteChannel(ChannelDBISAR? channelDB) {
    _loadData();
  }
}
