import 'package:flutter/material.dart';
import 'package:ox_chat/model/option_model.dart';
import 'package:ox_chat/page/contacts/contact_user_info_page.dart';
import 'package:ox_chat/utils/widget_tool.dart';
import 'package:ox_chat/widget/alpha.dart';
import 'package:ox_chat/widget/group_member_item.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:chatcore/chat-core.dart';
import 'package:lpinyin/lpinyin.dart';

enum GroupListAction {
  view,
  create,
  add,
  remove,
  send
}

class ContactGroupListPage extends StatefulWidget {
  final List<UserDBISAR>? userList;
  final GroupListAction? groupListAction;
  final String? title;
  final String? searchBarHintText;
  final GroupType? groupType;

  const ContactGroupListPage({
    super.key,
    this.userList,
    required this.title,
    this.groupListAction = GroupListAction.view,
    this.searchBarHintText,
    this.groupType,
  });

  @override
  State<ContactGroupListPage> createState() => ContactGroupListPageState();
}

class ContactGroupListPageState<T extends ContactGroupListPage> extends State<T> {

  List<UserDBISAR> userList = [];
  List<UserDBISAR> _filteredUserList = [];
  List<UserDBISAR> _selectedUserList = [];
  ValueNotifier<bool> _isClear = ValueNotifier(false);
  TextEditingController _controller = TextEditingController();
  Map<String, List<UserDBISAR>> _groupedUserList = {};
  Map<String, List<UserDBISAR>> _filteredGroupedUserList = {};

  List<UserDBISAR> get selectedUserList=> _selectedUserList;

  @override
  void initState() {
    super.initState();
    if(widget.userList != null){
      userList = widget.userList!;
      groupedUser();
    }
    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        _isClear.value = true;
      } else {
        _isClear.value = false;
      }
    });
  }

  groupedUser({String? specialPubkey}){
    ALPHAS_INDEX.forEach((v) {
      _groupedUserList[v] = [];
    });
    Map<UserDBISAR, String> pinyinMap = Map<UserDBISAR, String>();
    for (var user in userList) {
      if(specialPubkey != null && user.pubKey == specialPubkey){
        pinyinMap[user] = '☆';
        continue;
      }
      String nameToConvert = user.nickName != null && user.nickName!.isNotEmpty ? user.nickName! : (user.name ?? '');
      String pinyin = PinyinHelper.getFirstWordPinyin(nameToConvert);
      pinyinMap[user] = pinyin;
    }
    userList.sort((v1, v2) {
      return pinyinMap[v1]!.compareTo(pinyinMap[v2]!);
    });

    userList.forEach((item) {
      var firstLetter = pinyinMap[item]![0].toUpperCase();
      if (!ALPHAS_INDEX.contains(firstLetter)) {
        firstLetter = '#';
      }
      _groupedUserList[firstLetter]?.add(item);
    });

    _groupedUserList.removeWhere((key, value) => value.isEmpty);
    _filteredGroupedUserList = _groupedUserList;
    _filteredUserList = userList;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.color190,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(Adapt.px(20)),
            topLeft: Radius.circular(Adapt.px(20)),
          ),
        ),
        child: Container(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildAppBar(),
        _buildSearchBar(),
        Expanded(
          child: widget.groupListAction != GroupListAction.view
              ? ListView.builder(
                  itemCount: _filteredGroupedUserList.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key = _filteredGroupedUserList.keys.elementAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            child: Text(
                          key,
                          style: TextStyle(
                              color: ThemeColor.color0,
                              fontSize: Adapt.px(16),
                              fontWeight: FontWeight.w600),
                        ),margin: EdgeInsets.only(bottom: Adapt.px(4)),),
                        ..._filteredGroupedUserList[key]!.map((user) => _buildUserItem(user)),
                      ],
                    );
                  },
                )
              : ListView.builder(
                  itemCount: _filteredUserList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildUserItem(_filteredUserList[index]);
                  },
                ),
        ),
      ],
    ).setPadding(EdgeInsets.symmetric(horizontal: Adapt.px(24)));
  }

  String buildTitle() {
    return widget.title ?? '';
  }

  Widget _buildTitleWidget() {
    return Text(
      buildTitle(),
      style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: Adapt.px(16),
          color: ThemeColor.color0),
    );
  }

  Widget buildEditButton() {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: widget.groupListAction != GroupListAction.view
          ? CommonImage(
        iconName: 'icon_done.png',
        width: Adapt.px(24),
        height: Adapt.px(24),
        useTheme: true,
      )
          : CommonImage(
        iconName: 'icon_add.png',
        width: Adapt.px(24),
        height: Adapt.px(24),
        package: 'ox_chat',
        useTheme: true,
      ),
      onPressed: () {
        // widget.groupListAction == GroupListAction.view ? buildViewPressed() : widget.groupListAction == GroupListAction.add ? buildAddPressed() : buildRemovePressed();
        switch (widget.groupListAction) {
          case GroupListAction.view:
            buildViewPressed();
            break;
          case GroupListAction.add:
            buildAddPressed();
            break;
          case GroupListAction.remove:
            buildRemovePressed();
            break;
          case GroupListAction.send:
            buildSendPressed();
            break;
          default:
            break;
        }
      }
    );
  }

  Widget _buildAppBar(){
    return Container(
      height: Adapt.px(57),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              child: CommonImage(
                iconName: "icon_back_left_arrow.png",
                width: Adapt.px(24),
                height: Adapt.px(24),
                useTheme: true,
              ),
              onTap: () {
                OXNavigator.pop(context);
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _buildTitleWidget(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: buildEditButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ThemeColor.color180,
        ),
        height: Adapt.px(48),
        padding: EdgeInsets.symmetric(horizontal: Adapt.px(16)),
        margin: EdgeInsets.symmetric(vertical: Adapt.px(16)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  fontSize: Adapt.px(16),
                  fontWeight: FontWeight.w600,
                  height: Adapt.px(22.4) / Adapt.px(16),
                  color: ThemeColor.color0,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  icon: Container(
                    child: CommonImage(
                      iconName: 'icon_search.png',
                      width: Adapt.px(24),
                      height: Adapt.px(24),
                      fit: BoxFit.fill,
                    ),
                  ),
                  hintText: widget.searchBarHintText ?? 'search'.localized(),
                  hintStyle: TextStyle(
                    fontSize: Adapt.px(16),
                    fontWeight: FontWeight.w400,
                    height: Adapt.px(22.4) / Adapt.px(16),
                    color: ThemeColor.color160,
                  ),
                  border: InputBorder.none,
                ),
                textAlignVertical: TextAlignVertical.center,
                onChanged: _handlingSearch,
              ),
            ),
            ValueListenableBuilder(
              builder: (context, value, child) {
                return _isClear.value
                    ? GestureDetector(
                        onTap: () {
                          _controller.clear();
                          setState(() {
                            _filteredGroupedUserList = _groupedUserList;
                            _filteredUserList = userList;
                          });
                        },
                        child: CommonImage(
                          iconName: 'icon_textfield_close.png',
                          width: Adapt.px(16),
                          height: Adapt.px(16),
                        ),
                      )
                    : Container();
              },
              valueListenable: _isClear,
            ),
          ],
        ));
  }

  Widget _buildUserItem(UserDBISAR user){
    bool isSelected = _selectedUserList.contains(user);

    return GroupMemberItem(
      user: user,
      action: widget.groupListAction != GroupListAction.view
          ? CommonImage(
              width: Adapt.px(24),
              height: Adapt.px(24),
              iconName: isSelected ? 'icon_select_follows.png' : 'icon_unSelect_follows.png',
              package: 'ox_chat',) : SizedBox(),
      titleColor: isSelected ? ThemeColor.color0 : ThemeColor.color100,
      onTap: () {
        if (widget.groupListAction != GroupListAction.view) {
          if (!isSelected) {
            _selectedUserList.add(user);
          } else {
            _selectedUserList.remove(user);
          }
          setState(() {});
        }else{
          OXNavigator.pushPage(context, (context) => ContactUserInfoPage(pubkey: user.pubKey,));
        }
      },
    );
  }

  void _handlingSearch(String searchQuery)async {
    if(widget.groupListAction == GroupListAction.add && Account.sharedInstance.isValidPubKey(UserDBISAR.decodePubkey(searchQuery) ?? '')){
      _searchUser(searchQuery);
      return;
    }

    if (widget.groupListAction == GroupListAction.view) {
      _handlingViewActionSearch(searchQuery);
      return;
    }

    setState(() {
      Map<String, List<UserDBISAR>> searchResult = {};
      _groupedUserList.forEach((key, value) {
        List<UserDBISAR> tempList = value.where((item) {
          if(item.name!.toLowerCase().contains(searchQuery.toLowerCase())){
            return true;
          }

          if(item.encodedPubkey.toLowerCase().contains(searchQuery.toLowerCase())){
            return true;
          }

          return false;
        }).toList();
        searchResult[key] = tempList;
      });
      searchResult.removeWhere((key, value) => value.isEmpty);
      _filteredGroupedUserList = searchResult;
    });
  }

  void _searchUser(String searchQuery) async {
    UserDBISAR? user = await Account.sharedInstance.getUserInfo(UserDBISAR.decodePubkey(searchQuery)!);
    if (user == null) return;
    String tag = user.name ?? '';
    if(tag.isNotEmpty){
      tag = tag.substring(0,1).toUpperCase();
    }

    _filteredGroupedUserList = {
      tag :  [user]
    };
    setState(() {});
  }

  void _handlingViewActionSearch(String searchQuery) {
    List<UserDBISAR> searchResult = userList.where((item) {
      if (item.name!.toLowerCase().contains(searchQuery.toLowerCase())) {
        return true;
      }

      if (item.encodedPubkey
          .toLowerCase()
          .contains(searchQuery.toLowerCase())) {
        return true;
      }

      return false;
    }).toList();

    setState(() {
      _filteredUserList = searchResult;
    });
  }

  buildViewPressed() {}

  buildAddPressed() {}

  buildRemovePressed() {}

  buildSendPressed() {}
}

