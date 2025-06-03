import 'package:flutter/material.dart';
// ox_common
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/base_page_state.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/const/common_constant.dart';

import 'package:ox_login/page/save_account_page.dart';
import 'package:ox_module_service/ox_module_service.dart';
// component
import '../component/common_input.dart';
import '../component/input_wrap.dart';
import '../component/lose_focus_wrap.dart';
// plugin
import 'package:chatcore/chat-core.dart';
import 'package:ox_localizable/ox_localizable.dart';
export 'package:visibility_detector/visibility_detector.dart';
import 'package:nostr_core_dart/nostr.dart';

///Title: create_account
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2023/4/25 09:40
class CreateAccountPage extends StatefulWidget {
  final Keychain keychain;

  CreateAccountPage({required this.keychain});

  @override
  State<StatefulWidget> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends BasePageState<CreateAccountPage> {
  TextEditingController _userNameTextEditingController =
      new TextEditingController();
  TextEditingController _dnsTextEditingController = new TextEditingController();
  TextEditingController _aboutTextEditingController =
      new TextEditingController();

  String dnsSuffix = '@0xchat.com';

  @override
  String get routeName => 'CreateAccount';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        backgroundColor: ThemeColor.color200,
        useLargeTitle: false,
        centerTitle: true,
        title: '',
      ),
      backgroundColor: ThemeColor.color200,
      body: LoseFocusWrap(_body()),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  ThemeColor.gradientMainEnd,
                  ThemeColor.gradientMainStart,
                ],
              ).createShader(Offset.zero & bounds.size);
            },
            child: Text(
              Localized.text('ox_login.create_account'),
              style: TextStyle(
                fontSize: Adapt.px(32),
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ).setPadding(
            EdgeInsets.symmetric(
              vertical: Adapt.px(28),
            ),
          ),
          InputWrap(
            title: Localized.text('ox_login.username'),
            contentWidget: CommonInput(
              hintText: 'Satoshi',
              textController: _userNameTextEditingController,
            ),
          ),
          InputWrap(
            title: Localized.text('ox_login.about'),
            contentWidget: CommonInput(
              hintText: 'Bitcoin Core Dev (Optional)',
              textController: _aboutTextEditingController,
              maxLines: null,
            ),
          ),
          InputWrap(
            title: Localized.text('ox_login.account_id'),
            contentWidget: Text(
              Nip19.encodePubkey(widget.keychain.public),
              style: TextStyle(
                fontSize: Adapt.px(16),
                color: ThemeColor.color40,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            height: Adapt.px(18),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _create,
            child: Container(
              width: double.infinity,
              height: Adapt.px(48),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ThemeColor.color180,
                gradient: LinearGradient(
                  colors: [
                    ThemeColor.gradientMainEnd,
                    ThemeColor.gradientMainStart,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                Localized.text('ox_login.create'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Adapt.px(16),
                ),
              ),
            ),
          ),
        ],
      ).setPadding(EdgeInsets.symmetric(
        horizontal: Adapt.px(30),
      )),
    );
  }

  void _create() async {
    bool checkResult = await _checkForm();
    if (!checkResult) return;
    String dnsText = _dnsTextEditingController.text;
    String userName = _userNameTextEditingController.text;
    String userAbout = _aboutTextEditingController.text;
    String userDns = dnsText.length == 0 ? '' : dnsText + dnsSuffix;
    OXNavigator.pushPage(context, (context) => SaveAccountPage(userName: userName, userAbout: userAbout, userDns: userDns, keychain: widget.keychain));
  }

  Future<bool> _checkForm() async {
    bool userNameIsEmpty = _userNameTextEditingController.text.length == 0;
    if (userNameIsEmpty) {
      CommonToast.instance.show(context, 'The user name cannot be empty');
      return false;
    }

    String dnsText = _dnsTextEditingController.text;
    if (dnsText.length > 0) {
      String pubKey = widget.keychain.public;
      String nip05Url = dnsText + dnsSuffix;

      Map<String, dynamic>? dnsParams = {
        "name": _userNameTextEditingController.text,
        "publicKey": pubKey,
        'relays': [CommonConstant.oxChatRelay],
        "nip05Url": nip05Url,
        'sig': await signData([
          pubKey,
          nip05Url,
          [CommonConstant.oxChatRelay]
        ],Account.sharedInstance.currentPubkey, Account.sharedInstance.currentPrivkey)
      };

      Map<String, dynamic>? dnsResult = OXModuleService.invoke(
          'ox_usercenter',
          'requestVerifyDNS',
          [dnsParams, context, null, null]);
      if (dnsResult == null || dnsResult['code'] != '000000') {
        _dnsTextEditingController.text = '';
        String toastText =
            dnsResult == null ? 'DNS unavailable' : dnsResult['message'];
        CommonToast.instance.show(context, toastText);
        return false;
      }
    }

    return true;
  }
}
