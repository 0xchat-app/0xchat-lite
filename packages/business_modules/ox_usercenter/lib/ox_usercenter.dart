import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/model/wallet_model.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/utils/user_config_tool.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:ox_usercenter/model/request_verify_dns.dart';
import 'package:ox_usercenter/page/badge/usercenter_badge_wall_page.dart';
import 'package:ox_usercenter/page/set_up/avatar_preview_page.dart';
import 'package:ox_usercenter/page/set_up/relay_detail_page.dart';
import 'package:ox_usercenter/page/set_up/relays_for_login_page.dart';
import 'package:ox_usercenter/page/set_up/relays_page.dart';
import 'package:ox_usercenter/page/set_up/relays_selector_dialog.dart';
import 'package:ox_usercenter/page/set_up/verify_passcode_page.dart';
import 'package:ox_usercenter/page/set_up/zaps_invoice_dialog.dart';
import 'package:ox_usercenter/page/set_up/zaps_page.dart';
import 'package:ox_usercenter/page/set_up/zaps_record_page.dart';
import 'package:ox_usercenter/page/settings/settings_slider.dart';
import 'package:ox_usercenter/page/usercenter_page.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_usercenter/utils/zaps_helper.dart';
import 'package:ox_common/launch/launch_third_party_app.dart';

class OXUserCenter extends OXFlutterModule {

  static String get loginPageId => "usercenter_page";

  @override
  Future<void> setup() async {
    await super.setup();
    // ChatBinding.instance.setup();
  }

  @override
  // TODO: implement moduleName
  String get moduleName => OXUserCenterInterface.moduleName;

  @override
  Map<String, Function> get interfaces => {
        'showRelayPage': showRelayPage,
        'showRelaySelectorDialog': showRelaySelectorDialog,
        'requestVerifyDNS': requestVerifyDNS,
        'userCenterPageWidget': userCenterPageWidget,
        'showZapsInvoiceDialog': _showZapsInvoiceDialog,
        'getInvoice': _getInvoice,
        'showUserCenterBadgeWallPage':showUserCenterBadgeWallPage,
        'settingSliderBuilder': settingSliderBuilder
      };

  @override
  Future<T?>? navigateToPage<T>(BuildContext context, String pageName, Map<String, dynamic>? params) {
    switch (pageName) {
      case 'UserCenterPage':
        return OXNavigator.pushPage(
          context,
          (context) => const UserCenterPage(),
        );
      case 'UsercenterBadgeWallPage':
        UserDBISAR? userDB = params?['userDB'];
        return OXNavigator.pushPage(context, (context) => UsercenterBadgeWallPage(userDB: userDB,));
      case 'AvatarPreviewPage':
        UserDBISAR? userDB = params?['userDB'];
        return OXNavigator.pushPage(context, (context) => AvatarPreviewPage(userDB: userDB),);
      case 'ZapsInvoiceDialog':
        final invoice = params?['invoice'];
        final walletOnPress = params?['walletOnPress'];
        final nwcCompleted = params?['nwcCompleted'];
        final isCalledFromEcashWallet = params?['isCalledFromEcashWallet'] ?? false;
        return _showZapDialog(context, invoice, walletOnPress, nwcCompleted, isCalledFromEcashWallet);
      case 'ZapsRecordPage':
        final zapsDetail = params?['zapsDetail'];
        return OXNavigator.pushPage(context, (context) => ZapsRecordPage(zapsRecordDetail: zapsDetail));
      case 'RelayDetailPage':
        final relayName = params?['relayName'];
        return OXNavigator.pushPage(context, (context) => RelayDetailPage(relayURL: relayName,));
      case 'VerifyPasscodePage':
        return OXNavigator.pushReplacement(context, const VerifyPasscodePage());
      case 'ZapsSettingPage':
        return OXNavigator.pushPage(context, (context) => ZapsPage(onChanged: params?['onChanged'],));
      case 'RelaysForLoginPage':
        return OXNavigator.pushPage(context, (context) => RelaysForLoginPage(relayUrls: params?['relayUrls'],));
    }
    return null;
  }

   _showZapDialog(context, invoice, walletOnPress, Function()? nwcCompleted, [bool isCalledFromEcashWallet = false]) async {
     bool isShowWalletSelector = UserConfigTool.getSetting(StorageSettingKey.KEY_IS_SHOW_WALLET_SELECTOR.name, defaultValue: true);
     String defaultWalletName = UserConfigTool.getSetting(StorageSettingKey.KEY_DEFAULT_WALLET.name,defaultValue: '');
     final ecashWalletName = WalletModel.walletsWithEcash.first.title;
     if(isShowWalletSelector || defaultWalletName == ecashWalletName){
       return OXNavigator.pushPage(
         context,
         (context) {
           return ZapsInvoiceDialog(
             invoice: invoice,
             walletOnPress: walletOnPress,
             isShowEcashWallet: !isCalledFromEcashWallet,
           );
         },
         type: OXPushPageType.present,
       );
     }
     else if(defaultWalletName == 'NWC'){
       OXLoading.show();
       await Zaps.sharedInstance.requestNWC(invoice);
       WalletModel walletModel = WalletModel.wallets.where((element) => element.title == defaultWalletName).toList().first;
       walletOnPress?.call(walletModel);
       nwcCompleted?.call();
       OXLoading.dismiss();
     }
     else if(defaultWalletName.isNotEmpty){
       WalletModel walletModel = WalletModel.wallets.where((element) => element.title == defaultWalletName).toList().first;
       walletOnPress?.call(walletModel);
       _onTap(context, invoice, walletModel);
     }
     else{
       CommonToast.instance.show(context, "Please set the default wallet first");
     }
  }

  void _onTap(context, invoice, walletModel) async {
    String url = '${walletModel.scheme}$invoice';
    if (Platform.isIOS) {
      LaunchThirdPartyApp.openWallet(url, walletModel.appStoreUrl ?? '', context: context);
    } else if (Platform.isAndroid) {
      LaunchThirdPartyApp.openWallet(url, walletModel.playStoreUrl ?? '', context: context);
    }
  }

  void showRelayPage(BuildContext context) {
    OXNavigator.pushPage(context, (context) => const RelaysPage());
  }

  void showRelaySelectorDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const RelaysSelectorPage();
        });
  }

  Future<Map<String, dynamic>?> requestVerifyDNS(Map<String, dynamic>? params, BuildContext? context, bool? showErrorToast, bool? showLoading) async {
    return await registerNip05(context: context, params: params, showLoading: showLoading, showErrorToast: showErrorToast);
  }

  Widget userCenterPageWidget(BuildContext context) {
    return const UserCenterPage();
  }


  void _showZapsInvoiceDialog(BuildContext context, String invoice) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ZapsInvoiceDialog(invoice: invoice);
        });
  }

  Future<Map<String, String>> _getInvoice({
    required int sats,
    required String recipient,
    required String otherLnurl,
    String? content,
    String? eventId,
    ZapType? zapType,
    String? receiver,
    String? groupId,
    bool privateZap = false,
  }) async {
    return await ZapsHelper.getInvoice(
      sats: sats,
      recipient: recipient,
      otherLnurl: otherLnurl,
      content: content,
      eventId: eventId,
      privateZap: privateZap,
      zapType: zapType,
      receiver: receiver,
      groupId: groupId
    );
  }

  Widget showUserCenterBadgeWallPage(BuildContext? context, {required UserDBISAR userDB,bool isShowTabBar = true,bool isShowBadgeAwards = true,}) {
    return  UsercenterBadgeWallPage(userDB: userDB, isShowTabBar:isShowTabBar,isShowBadgeAwards:isShowBadgeAwards);
  }

  Widget settingSliderBuilder(BuildContext context) {
    return const SettingSlider();
  }
}
