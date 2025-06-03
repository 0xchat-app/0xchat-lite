
import 'package:flutter/material.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:chatcore/chat-core.dart';

import '../session/chat_message_page.dart';

class ContactGroupsWidget extends StatefulWidget {
  final UserDBISAR userDB;
  ContactGroupsWidget({required this.userDB});

  @override
  ContactGroupsWidgetState createState() => new ContactGroupsWidgetState();
}

class ContactGroupsWidgetState extends State<ContactGroupsWidget> {
  List<RelayGroupDBISAR> groups = [];
  @override
  void initState() {
    super.initState();
    _getGroupsList();
  }

  @override
  void dispose() {

    super.dispose();
  }

  void _getGroupsList(){
    Map<String, ValueNotifier<RelayGroupDBISAR>> draftGroups = RelayGroup.sharedInstance.groups;
    List<RelayGroupDBISAR> filterGroups = [];
    draftGroups.values.map((ValueNotifier<RelayGroupDBISAR> element) {
      if(element.value.members != null){
        int findIndex = element.value.members!.indexOf(widget.userDB.pubKey);
        if(findIndex != -1) {
          filterGroups.add(element.value);
        }
      }
    }).toList();
    groups = filterGroups;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return groups.isEmpty ?  _noDataWidget() : _groupItemWidgetList();
  }

  Widget _groupItemWidget(index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: ()  {
        final groupDB = groups[index];
        ChatMessagePage.open(
          context: context,
          communityItem: ChatSessionModelISAR(
            chatId: groupDB.groupId,
            groupId: groupDB.groupId,
            chatType: ChatType.chatRelayGroup,
            chatName: groupDB.name,
            avatar: groupDB.picture,
          ),
          isPushWithReplace: false,
        );
      },
      child: Container(
        child: Row(
          children: [
            OXRelayGroupAvatar(
              relayGroup: groups[index],
              size: 40.px,
              isClickable: true,
              onReturnFromNextPage: () {
                setState(() { });
              },
            ).setPaddingOnly(right: 16.px),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200.px,
                  child: Text(
                    groups[index].name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ThemeColor.color0,
                      fontSize: 14.px,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).setPaddingOnly(bottom: 2.px),
               if(groups[index].about.isNotEmpty)
               Container(
                 width: 200.px,
                 child:Text(
                   groups[index].about,
                   overflow: TextOverflow.ellipsis,
                   style: TextStyle(
                     color: ThemeColor.color120,
                     fontSize: 12.px,
                     fontWeight: FontWeight.w400,
                   ),
                 ),
               ),
              ],
            ),
          ],
        ),
      ).setPadding(EdgeInsets.symmetric(horizontal: 24.px,vertical: 8.px)),
    );
  }

  ListView _groupItemWidgetList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      primary: true,
      shrinkWrap: true,
      itemCount: groups.length,
      itemBuilder: (context, index) => _groupItemWidget(index),
    );
  }


  Widget _noDataWidget() {
    return Container(
      padding: EdgeInsets.only(
        top: 100.px,
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
              'No Groups',
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



}
