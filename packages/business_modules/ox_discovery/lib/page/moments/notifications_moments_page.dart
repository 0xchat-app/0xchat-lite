import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_network_image.dart';
import 'package:ox_common/widgets/common_pull_refresher.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_discovery/model/aggregated_notification.dart';
import 'package:ox_discovery/model/moment_extension_model.dart';
import 'package:ox_discovery/page/moments/moments_page.dart';
import 'package:ox_discovery/page/widgets/moment_rich_text_widget.dart';
import 'package:ox_discovery/utils/discovery_utils.dart';
import 'package:ox_discovery/utils/moment_content_analyze_utils.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';

import '../../enum/moment_enum.dart';
import '../../model/moment_ui_model.dart';
import '../../utils/moment_widgets_utils.dart';

class NotificationsMomentsPage extends StatefulWidget {
  const NotificationsMomentsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsMomentsPage> createState() =>
      _NotificationsMomentsPageState();
}

class _NotificationsMomentsPageState extends State<NotificationsMomentsPage> {
  final int _limit = 50;
  int? _lastTimestamp;
  final RefreshController _refreshController = RefreshController();
  final List<AggregatedNotification> _aggregatedNotifications = [];

  @override
  void initState() {
    super.initState();
    _lastTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _loadNotificationData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.color200,
      appBar: CommonAppBar(
        backgroundColor: ThemeColor.color200,
        actions: [
          _isShowClearWidget(),
        ],
        title: Localized.text('ox_discovery.notifications'),
      ),
      body: _bodyWidget(),
    );
  }

  Widget _isShowClearWidget(){
    if(_aggregatedNotifications.isEmpty) return const SizedBox();
    return GestureDetector(
      onTap: _clearNotifications,
      child: Container(
        alignment: Alignment.center,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                ThemeColor.gradientMainEnd,
                ThemeColor.gradientMainStart,
              ],
            ).createShader(Offset.zero & bounds.size);
          },
          child: Text(
            Localized.text('ox_discovery.clear'),
            style: TextStyle(
              fontSize: 16.px,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyWidget(){
    if(_aggregatedNotifications.isEmpty) return _noDataWidget();
    return OXSmartRefresher(
      controller: _refreshController,
      enablePullDown: false,
      enablePullUp: true,
      onLoading: () => _loadNotificationData(),
      child: SingleChildScrollView(
        child: ListView.builder(
          primary: false,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _aggregatedNotifications.length,
          itemBuilder: (context, index) {
            return _notificationsItemWidget(notification: _aggregatedNotifications[index]);
          },
        ),
      ),
    );
  }

  Widget _noDataWidget(){
    return Padding(
      padding: EdgeInsets.only(
        top: 120.px,
      ),
      child: Center(
        child: Column(
          children: [
            CommonImage(
              iconName: 'icon_no_data.png',
              width: Adapt.px(90),
              height: Adapt.px(90),
            ),
            Text(
              Localized.text('ox_discovery.notifications_no_data'),
              style: TextStyle(
                fontSize: 16.px,
                fontWeight: FontWeight.w400,
                color: ThemeColor.color100,
              ),
            ).setPaddingOnly(
              top: 24.px,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationsItemWidget({required AggregatedNotification notification}) {
    ENotificationsMomentType type = _fromIndex(notification.kind);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _jumpMomentsPage(type,notification),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24.px,
          vertical: 12.px,
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 1.px,
          color: ThemeColor.color180,
        ))),
        child: FutureBuilder<UserDBISAR?>(
          future: _getUser(notification.author),
          builder: (context,snapshot) {
            final placeholder = MomentWidgetsUtils.badgePlaceholderImage(size: 40);

            if(snapshot.data == null) return Container();
            final user = snapshot.data!;
            final likeCount = notification.likeCount;
            final username = user.name ?? user.shortEncodedPubkey ?? '';
            final suffix = (likeCount - 1) > 0 ? 'and ${notification.likeCount - 1} people' : '';
            final itemLabel = type == ENotificationsMomentType.like ? '$username $suffix' : username;
            final imageUrl = snapshot.data?.picture ?? '';
            String showTimeContent = DiscoveryUtils.formatTimeAgo(notification.createAt);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        OXModuleService.pushPage(
                            context, 'ox_chat', 'ContactUserInfoPage', {
                          'pubkey': user.pubKey,
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40.px),
                        child: OXCachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 40.px,
                          height: 40.px,
                          placeholder: (context, url) => placeholder,
                          errorWidget: (context, url, error) => placeholder,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 8.px,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                itemLabel,
                                style: TextStyle(
                                  color: ThemeColor.color0,
                                  fontSize: 14.px,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: 8.px,
                              ),
                              Text(
                                showTimeContent,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ThemeColor.color120,
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ).setPaddingOnly(bottom: 2.px),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  right: 4.px,
                                ),
                                child: CommonImage(
                                  iconName: type.getIconName,
                                  size: 16.px,
                                  package: 'ox_discovery',
                                  color: ThemeColor.gradientMainStart,
                                ),
                              ),
                              _getNotificationsContentWidget(type,notification),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildThumbnailWidget(notification),
              ],
            );
          }
        ),
      ),
    );
  }

  Future<UserDBISAR?> _getUser(String pubkey) async {
    return await Account.sharedInstance.getUserInfo(pubkey);
  }

  Widget _getNotificationsContentWidget(type,AggregatedNotification notificationDB) {
    return  FutureBuilder(
        future: _getNote(notificationDB),
        builder: (context,snapshot) {
          ENotificationsMomentType type = _fromIndex(notificationDB.kind);
          String content = '';
          bool isOptionMe = true;
          if(snapshot.data != null){
            if(snapshot.data!.author.toLowerCase() != (OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey.toLowerCase() ?? '')){
              isOptionMe = false;
            }
          }
          switch (type) {
            case ENotificationsMomentType.quote:
            case ENotificationsMomentType.reply:
              content = isOptionMe ? notificationDB.content : 'replied a note you were mentioned in';
              break;
            case ENotificationsMomentType.like:
              content = isOptionMe ? Localized.text('ox_discovery.liked_moments_tips') : 'liked a note you were mentioned in';
              break;
            case ENotificationsMomentType.repost:
              content = isOptionMe ? Localized.text('ox_discovery.reposted_moments_tips') : 'reposted a note you were mentioned in';
              break;
            case ENotificationsMomentType.zaps:
              content = "${Localized.text('ox_discovery.zaps')} +${notificationDB.zapAmount}";
              break;
          }
          bool isPurpleColor = type != ENotificationsMomentType.quote &&
              type != ENotificationsMomentType.reply;
          return  SizedBox(
                width: 200.px,
                child: MomentRichTextWidget(
                  text: content,
                  defaultTextColor: isPurpleColor ? ThemeColor.purple2 : ThemeColor.color0,
                  textSize: 12.px,
                  maxLines: 2,
                  isShowAllContent: false,
                  clickBlankCallback:() => _jumpMomentsPage(type,notificationDB),
                ),

          );
        }
    );
  }

  Widget _buildThumbnailWidget(AggregatedNotification notificationDB) {
    return FutureBuilder(
      future: _getNote(notificationDB),
      builder: (context,snapshot) {
        final note = snapshot.data;
        if(note == null) return Container();
        MomentContentAnalyzeUtils mediaAnalyzer = MomentContentAnalyzeUtils(note.content ?? '');
        List<String> pictures = mediaAnalyzer.getMediaList(1);
        if(pictures.isEmpty) return Container();
        return MomentWidgetsUtils.clipImage(
          borderRadius: 8.px,
          imageSize: 60.px,
          child: OXCachedNetworkImage(
            imageUrl: pictures.first,
            fit: BoxFit.cover,
            placeholder: (context, url) => MomentWidgetsUtils.badgePlaceholderImage(),
            errorWidget: (context, url, error) => MomentWidgetsUtils.badgePlaceholderImage(),
            width: 60.px,
            height: 60.px,
          ),
        );
      }
    );
  }

  Future<NoteDBISAR?> _getNote(AggregatedNotification notificationDB) async {
    NotedUIModel? noteNotifier = await OXMomentCacheManager.getValueNotifierNoted(
      notificationDB.associatedNoteId,
      isUpdateCache: true,
    );
    if(noteNotifier == null) return null;

    return noteNotifier.noteDB;
  }

  void _clearNotifications(){
    OXCommonHintDialog.show(
      context,
      title: '',
      content: Localized.text('ox_discovery.clear_tips'),
      actionList: [
        OXCommonHintAction.cancel(onTap: () {
          OXNavigator.pop(context);
        }),
        OXCommonHintAction.sure(text: Localized.text('ox_common.confirm'), onTap: () async {
          OXLoading.show();
          await Moment.sharedInstance.deleteAllNotifications();
          OXLoading.dismiss();
          setState(() {
            _aggregatedNotifications.clear();
          });
          CommonToast.instance.show(context, Localized.text('ox_discovery.clear_success_tips'));
         return OXNavigator.pop(context);
        }),
      ],
      isRowAction: true,
    );

  }

  _loadNotificationData() async {
    List<NotificationDBISAR> notificationList = await Moment.sharedInstance.loadNotificationsFromDB(_lastTimestamp ?? 0,limit: _limit) ?? [];

    List<AggregatedNotification> aggregatedNotifications = _getAggregatedNotifications(notificationList);
    _aggregatedNotifications.addAll(aggregatedNotifications);
    _lastTimestamp = notificationList.last.createAt;
    notificationList.length < _limit ? _refreshController.loadNoData() : _refreshController.loadComplete();
    setState(() {});
  }

  ENotificationsMomentType _fromIndex(int kind) {
    //1：reply 2:quoteRepost 6:repost 7:reaction 9735:zap
    switch (kind) {
      case 1 :
        return ENotificationsMomentType.reply;
      case 2 :
        return ENotificationsMomentType.quote;
      case 6 :
        return ENotificationsMomentType.repost;
      case 7 :
        return ENotificationsMomentType.like;
      case 9735 :
        return ENotificationsMomentType.zaps;
      default:
        return ENotificationsMomentType.reply;
    }
  }

  List<AggregatedNotification> _getAggregatedNotifications(List<NotificationDBISAR> notifications) {
    List<NotificationDBISAR> likeTypeNotification = [];
    List<NotificationDBISAR> otherTypeNotification = [];
    Set<String> groupedItems = {};

    for (var notification in notifications) {
      if (notification.isLike) {
        likeTypeNotification.add(notification);
        groupedItems.add(notification.associatedNoteId);
      } else {
        otherTypeNotification.add(notification);
      }
    }

    Map<String, List<NotificationDBISAR>> grouped = {};
    for (var groupedItem in groupedItems) {
      grouped[groupedItem] = likeTypeNotification.where((notification) => notification.associatedNoteId == groupedItem).toList();
    }

    List<AggregatedNotification> aggregatedNotifications = [];
    grouped.forEach((key, value) {
      value.sort((a, b) => b.createAt.compareTo(a.createAt)); // sort each group
      AggregatedNotification groupedNotification = AggregatedNotification.fromNotificationDB(value.first);
      groupedNotification.likeCount = value.length;
      aggregatedNotifications.add(groupedNotification);
    });

    aggregatedNotifications.addAll(otherTypeNotification.map((element) => AggregatedNotification.fromNotificationDB(element)));
    aggregatedNotifications.sort((a, b) => b.createAt.compareTo(a.createAt));

    return aggregatedNotifications;
  }

  void _jumpMomentsPage(ENotificationsMomentType type,AggregatedNotification notification)async {
    String noteId;
    if(type == ENotificationsMomentType.reply || type == ENotificationsMomentType.quote) {
      noteId = notification.notificationId;
    } else {
      noteId = notification.associatedNoteId;
    }

    NotedUIModel? noteNotifier = await OXMomentCacheManager.getValueNotifierNoted(
      noteId,
      isUpdateCache: true,
    );

    if(noteNotifier != null){
      OXNavigator.pushPage(context, (context) => MomentsPage(isShowReply: true, notedUIModel: noteNotifier));
    }
  }
}
