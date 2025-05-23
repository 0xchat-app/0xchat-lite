import 'dart:io';
import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/business_interface/ox_usercenter/interface.dart';
import 'package:ox_common/business_interface/ox_wallet/interface.dart';
import 'package:ox_common/launch/launch_third_party_app.dart';
import 'package:ox_common/model/wallet_model.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/utils/user_config_tool.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/zaps/zaps_assisted_page.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:cashu_dart/cashu_dart.dart';
import 'package:nostr_core_dart/nostr.dart';

class ZapsActionHandler {
  final UserDBISAR userDB;
  final bool isAssistedProcess;
  final bool? privateZap;
  final ZapType? zapType;
  final String? receiver;
  final String? groupId;
  Function(Map<String,dynamic> zapsInfo)? zapsInfoCallback;
  Function()? preprocessCallback;
  Function(Map<String,dynamic> zapsInfo)? nwcCompleted;

  late bool isDefaultEcashWallet;

  late bool isDefaultNWCWallet;

  late String defaultWalletName;
  late String defaultZapDescription;

  ZapsActionHandler({
    required this.userDB,
    this.privateZap,
    this.zapType,
    this.receiver,
    this.groupId,
    this.zapsInfoCallback,
    this.preprocessCallback,
    this.nwcCompleted,
    bool? isAssistedProcess,
  }) : isAssistedProcess = isAssistedProcess ?? false;

  static Future<ZapsActionHandler> create({
    required UserDBISAR userDB,
    bool? privateZap,
    ZapType? zapType,
    String? receiver,
    String? groupId,
    Function(Map<String, dynamic>)? zapsInfoCallback,
    Function()? preprocessCallback,
    bool? isAssistedProcess,
  }) async {
    ZapsActionHandler handler = ZapsActionHandler(
      userDB: userDB,
      privateZap: privateZap,
      zapType: zapType,
      receiver: receiver,
      groupId: groupId,
      zapsInfoCallback: zapsInfoCallback,
      preprocessCallback: preprocessCallback,
      isAssistedProcess: isAssistedProcess,
    );
    await handler.initialize();
    return handler;
  }

  Future<void> initialize() async {
    Map<String, dynamic> defaultWalletInfo = await getDefaultWalletInfo();
    isDefaultEcashWallet = defaultWalletInfo['isDefaultEcashWallet'];
    isDefaultNWCWallet = defaultWalletInfo['isDefaultNWCWallet'];
    defaultWalletName = defaultWalletInfo['defaultWalletName'];
    defaultZapDescription = defaultWalletInfo['defaultZapDescription'];
  }

  Future<Map<String, dynamic>> getDefaultWalletInfo() async {
    String? pubkey = Account.sharedInstance.me?.pubKey;
    if (pubkey == null) return {};
    String defaultWalletName = UserConfigTool.getSetting(StorageSettingKey.KEY_DEFAULT_WALLET.name, defaultValue: '');
    String defaultZapDescription = UserConfigTool.getSetting(
      StorageSettingKey.KEY_DEFAULT_ZAP_DESCRIPTION.name,
      defaultValue: Localized.text('ox_discovery.description_hint_text'),
    );
    final ecashWalletName = WalletModel.walletsWithEcash.first.title;

    final isDefaultEcashWallet = defaultWalletName == ecashWalletName;
    final isDefaultNWCWallet = defaultWalletName == 'NWC';
    final isDefaultThirdPartyWallet = !isDefaultEcashWallet && !isDefaultNWCWallet;

    return {
      'defaultWalletName': defaultWalletName,
      'isDefaultEcashWallet': isDefaultEcashWallet,
      'isDefaultNWCWallet': isDefaultNWCWallet,
      'isDefaultThirdPartyWallet': isDefaultThirdPartyWallet,
      'defaultZapDescription': defaultZapDescription,
    };
  }

  void setZapsInfoCallback(Function(Map<String, dynamic>) callback) {
    zapsInfoCallback = callback;
  }

  void removeZapsInfoCallback() {
    zapsInfoCallback = null;
  }

  void setPreprocessCallback(Function() callback){
    preprocessCallback = callback;
  }

  void removeCPreprocessCallback() {
    preprocessCallback = null;
  }

  Future<void> handleZap({
    required BuildContext context,
    int? zapAmount,
    String? eventId,
    String? description,
    bool? privateZap,
    ZapType? zapType,
    String? receiver,
    String? groupId,
  }) async {
    String lnurl = userDB.lnAddress;

    if (lnurl.isEmpty || lnurl == 'null') {
      await CommonToast.instance.show(context, Localized.text('ox_discovery.not_set_lnurl_tips'));
      return;
    }

    if (lnurl.contains('@')) {
      try {
        lnurl = await Zaps.getLnurlFromLnaddr(lnurl);
      } catch (error) {
        CommonToast.instance.show(context, Localized.text('ox_usercenter.enter_lnurl_address_toast'));
        return;
      }
    }

    if (isAssistedProcess) {
      OXNavigator.pushPage(
        context,
        (context) => ZapsAssistedPage(
          userDB: userDB,
          eventId: eventId,
          lnurl: lnurl,
          handler: this,
        ),
        type: OXPushPageType.present,
      );
    } else {
      // final showLoading = !isDefaultEcashWallet && !isDefaultNWCWallet;
      handleZapChannel(
        context,
        lnurl: lnurl,
        zapAmount: zapAmount,
        eventId: eventId,
        description: description ?? defaultZapDescription,
        privateZap: privateZap,
        showLoading: true,
        zapType: zapType,
        receiver: receiver,
        groupId: groupId
      );
    }
  }

  handleZapChannel(BuildContext context,{
    required String lnurl,
    int? zapAmount,
    String? eventId,
    String? description,
    bool? privateZap,
    ZapType? zapType,
    String? receiver,
    String? groupId,
    IMintIsar? mint,
    bool showLoading = false,
  }) async {
    final recipient = userDB.pubKey;
    zapAmount = zapAmount ?? UserConfigTool.getSetting(StorageSettingKey.KEY_DEFAULT_ZAP_AMOUNT.name, defaultValue: 21);
    if (isDefaultEcashWallet) {
      mint = mint ?? OXWalletInterface.getDefaultMint();
      String errorMsg = preprocessHandleZapWithEcash(mint, zapAmount!);
      if(errorMsg.isNotEmpty){
        await CommonToast.instance.show(context,errorMsg);
        return;
      }
      preprocessCallback?.call();
      if(showLoading) OXLoading.show();
      Map<String, dynamic> zapsInfo = await getInvoice(
        sats: zapAmount,
        recipient: recipient,
        lnurl: lnurl,
        eventId: eventId,
        description: description,
        privateZap: privateZap ?? false,
        zapType: zapType,
        receiver: receiver,
        groupId: groupId
      );
      bool result = await handleZapWithEcash(
        mint: mint!,
        zapsInfo: zapsInfo,
        context: context,
        showLoading: showLoading,
      );
      if(!result) return;
      if(context.widget is ZapsAssistedPage) OXNavigator.pop(context);
      zapsInfoCallback?.call(zapsInfo);
    } else if (isDefaultNWCWallet) {
      String nwcURI = Account.sharedInstance.me?.nwcURI ?? '';
      if(nwcURI.isEmpty) {
        await CommonToast.instance.show(context,'nwc not exit');
        return;
      }
      preprocessCallback?.call();
      if(showLoading) OXLoading.show();
      Map<String, dynamic> zapsInfo = await getInvoice(
          sats: zapAmount!,
          recipient: recipient,
          lnurl: lnurl,
          eventId: eventId,
          description: description,
          privateZap: privateZap ?? false,
          zapType: zapType,
          receiver: receiver,
          groupId: groupId
      );
      bool result = await handleZapWithNWC(zapsInfo: zapsInfo, context: context);
      if(!result) return;
      if(showLoading) OXLoading.dismiss();
      if(context.widget is ZapsAssistedPage) OXNavigator.pop(context);
      zapsInfoCallback?.call(zapsInfo);
    } else {
      if (defaultWalletName.isEmpty) {
        CommonToast.instance.show(context, 'Please select a payment wallet');
        return;
      }
      if(showLoading) OXLoading.show();
      Map<String, dynamic> zapsInfo = await getInvoice(
          sats: zapAmount!,
          recipient: recipient,
          lnurl: lnurl,
          eventId: eventId,
          description: description,
          privateZap: privateZap ?? false,
          zapType: zapType,
          receiver: receiver,
          groupId: groupId
      );
      if(showLoading) OXLoading.dismiss();
      await handleZapWithThirdPartyWallet(zapsInfo: zapsInfo, context: context);
      if(context.widget is ZapsAssistedPage) OXNavigator.pop(context);
      zapsInfoCallback?.call(zapsInfo);
    }
  }

  Future<bool> handleZapWithEcash({
    required IMintIsar mint,
    required Map zapsInfo,
    required BuildContext context,
    bool showLoading = false,
  }) async {
    String invoice = zapsInfo['invoice'];
    if(invoice.isEmpty) {
      await CommonToast.instance.show(context, 'Get Invoice Failed');
      return false;
    }
    final response = await Cashu.payingLightningInvoice(
      mint: mint,
      pr: invoice,
      processCallback: (statusText) {
        if (showLoading) {
          OXLoading.show(status: statusText);
        }
      }
    );
    if(showLoading) OXLoading.dismiss();
    if (OXWalletInterface.checkAndShowDialog(context, response, mint)) return false;
    if (!response.isSuccess) {
      await CommonToast.instance.show(context, response.errorMsg);
      return false;
    }
    CommonToast.instance.show(context, 'Zap Successful');
    return true;
  }

  Future<bool> handleZapWithNWC({
    required Map<String,dynamic> zapsInfo,
    required BuildContext context,
  }) async {
    final invoice = zapsInfo['invoice'];
    if(invoice.isEmpty) {
      await CommonToast.instance.show(context, 'Get Invoice Failed');
      return false;
    }
    OKEvent okEvent = await Zaps.sharedInstance.requestNWC(invoice);
    if(!okEvent.status) {
      await CommonToast.instance.show(context, 'NWC Payment Failed: ${okEvent.message}');
      return false;
    }
    CommonToast.instance.show(context, 'Zap Successful');
    nwcCompleted?.call(zapsInfo);
    return true;
  }

  handleZapWithThirdPartyWallet({
    required Map<String,dynamic> zapsInfo,
    required BuildContext context,
  }) async {
    WalletModel walletModel = WalletModel.wallets.firstWhere((element) => element.title == defaultWalletName);
    final invoice = zapsInfo['invoice'];
    String url = '${walletModel.scheme}$invoice';
    if (Platform.isIOS) {
      await LaunchThirdPartyApp.openWallet(url, walletModel.appStoreUrl, context: context);
    } else if (Platform.isAndroid) {
      await LaunchThirdPartyApp.openWallet(url, walletModel.playStoreUrl, context: context);
    }
  }

  Future<Map<String,dynamic>> getInvoice({
    required int sats,
    required String recipient,
    required String lnurl,
    String? description,
    String? eventId,
    bool privateZap = false,
    ZapType? zapType,
    String? receiver,
    String? groupId,
  }) async {
    final invokeResult = await OXUserCenterInterface.getInvoice(
      sats: sats,
      otherLnurl: lnurl,
      recipient: recipient,
      eventId: eventId,
      content: description,
      privateZap: privateZap,
      zapType: zapType,
      receiver: receiver,
      groupId: groupId
    );
    final invoice = invokeResult['invoice'] ?? '';
    final zapper = invokeResult['zapper'] ?? '';

    final zapsInfo = {
      'zapper': zapper,
      'invoice': invoice,
      'amount': sats.toString(),
      'description': description,
    };

    return zapsInfo;
  }

  String preprocessHandleZapWithEcash(
    IMintIsar? mint,
    int sats,
  ) {
    final isWalletAvailable = OXWalletInterface.isWalletAvailable() ?? false;
    if (!isWalletAvailable) return 'Please open Ecash Wallet first';
    if (mint == null) return Localized.text('ox_discovery.mint_empty_tips');
    if (sats < 1) return Localized.text('ox_discovery.enter_amount_tips');
    if (sats > mint.balance) return Localized.text('ox_discovery.insufficient_balance_tips');
    return '';
  }
}
