import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ox_common/business_interface/ox_usercenter/zaps_detail_model.dart';
import 'package:ox_common/model/wallet_model.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/user_config_tool.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_webview.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:ox_usercenter/model/zaps_record.dart';
import 'package:ox_usercenter/page/set_up/zaps_record_page.dart';
import 'package:chatcore/chat-core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ox_common/widgets/common_scan_page.dart';
import 'package:ox_common/utils/scan_utils.dart';


///Title: zaps_page
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2023/5/10 17:26
class ZapsPage extends StatefulWidget {
  final ValueSetter<bool>? onChanged;
  const ZapsPage({super.key,this.onChanged});

  @override
  State<StatefulWidget> createState() {
    return _ZapsPageState();
  }
}

class _ZapsPageState extends State<ZapsPage> {
  bool _walletSwitchSelected = true;
  final TextEditingController _zapAmountTextEditingController = TextEditingController();
  final TextEditingController _zapDescriptionController = TextEditingController();
  final List<WalletModel> _walletList = WalletModel.walletsWithEcash;
  String _selectedWalletName = '';
  ZapsRecord? _zapsRecord;
  String pubKey = '';
  int _defaultZapAmount = 0;
  String _defaultDescription = '';
  final FocusNode _focusNode = FocusNode();
  final FocusNode _descriptionFocusNote = FocusNode();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    pubKey = OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey ?? '';
    _selectedWalletName = UserConfigTool.getSetting(
        StorageSettingKey.KEY_DEFAULT_WALLET.name,
        defaultValue: Localized.text('ox_usercenter.not_set_wallet_status'));
    _walletSwitchSelected = UserConfigTool.getSetting(StorageSettingKey.KEY_IS_SHOW_WALLET_SELECTOR.name, defaultValue: true);
    _defaultZapAmount = UserConfigTool.getSetting(StorageSettingKey.KEY_DEFAULT_ZAP_AMOUNT.name, defaultValue: 21);
    _defaultDescription = UserConfigTool.getSetting(
      StorageSettingKey.KEY_DEFAULT_ZAP_DESCRIPTION.name,
      defaultValue: Localized.text('ox_discovery.description_hint_text'),
    );
    _zapsRecord = await getZapsRecord();
    _focusNode.addListener(_amountFocusNoteListener);
    _descriptionFocusNote.addListener(_descriptionFocusNoteListener);
    if(mounted){
      setState(() {});
    }

  }

  _amountFocusNoteListener() {
    if(!_focusNode.hasFocus){
      int zapAmount = int.parse(_zapAmountTextEditingController.text);
      UserConfigTool.saveSetting(StorageSettingKey.KEY_DEFAULT_ZAP_AMOUNT.name, zapAmount);
      widget.onChanged?.call(true);
    }
  }

  _descriptionFocusNoteListener() {
    if(!_descriptionFocusNote.hasFocus){
      String defaultZapDescription = _zapDescriptionController.text;
      defaultZapDescription = defaultZapDescription.isNotEmpty ? defaultZapDescription : _defaultDescription;
      UserConfigTool.saveSetting(StorageSettingKey.KEY_DEFAULT_ZAP_DESCRIPTION.name, defaultZapDescription);
      widget.onChanged?.call(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        backgroundColor: ThemeColor.color190,
        appBar: CommonAppBar(
          title: Localized.text('ox_usercenter.zaps'),
          centerTitle: true,
          useLargeTitle: false,
          titleTextColor: ThemeColor.color0,
        ),
        body: _body(),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

  Widget _body() {
    List<ZapsRecordDetail> zapsRecordDetails = _zapsRecord?.list ?? [];
    // String totalZaps = _totalZaps(_zapsRecord?.totalZaps ?? 0);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: PlatformUtils.listWidth,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildItem(
                label: Localized.text('ox_usercenter.zaps'),
                itemBody: Container(
                  width: double.infinity,
                  height: Adapt.px(104 + 0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Adapt.px(16)),
                    color: ThemeColor.color180,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildItemBody(
                          title:
                              Localized.text('ox_usercenter.show_wallet_selector'),
                          isShowDivider: true,
                          trailing: _buildWalletSelector(),
                          isShowArrow: false),
                      _buildItemBody(
                          title:
                              Localized.text('ox_usercenter.select_default_wallet'),
                          flag: _selectedWalletName,
                          onTap: () => _walletSelectorDialog()),
                    ],
                  ),
                ),
              ),
              _buildItem(
                label: 'Default zap amount in sats',
                itemBody: _buildInputView(
                  hitText: '$_defaultZapAmount',
                  controller: _zapAmountTextEditingController,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                ),
              ),

              _buildItem(
                label: 'Default zap message',
                itemBody: _buildInputView(
                  hitText: _defaultDescription,
                  controller: _zapDescriptionController,
                  focusNode: _descriptionFocusNote,
                ),
              ),
              // _buildItem(label: 'Cumulative Zaps', itemBody: _zapAmountView(hitText: totalZaps,enable: false)),
              zapsRecordDetails.isNotEmpty
                  ? _buildItem(
                      label: Localized.text('ox_usercenter.zaps_record'),
                      itemBody: _buildZapsRecord())
                  : Container(),
            ],
          ).setPadding(EdgeInsets.symmetric(
            horizontal: Adapt.px(24),
            vertical: Adapt.px(12),
          )),
        ),
      ),
    );
  }

  Widget _buildInputView(
      {String? hitText,
      TextEditingController? controller,
      bool? enable,
      FocusNode? focusNode,
      TextInputType? keyboardType,
      }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(16)),
        color: ThemeColor.color180,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: Adapt.px(16), vertical: Adapt.px(12)),
      child: TextField(
        readOnly: false,
        enabled: enable,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hitText,
          isCollapsed: true,
          hintStyle: TextStyle(
            fontSize: Adapt.px(16),
            fontWeight: FontWeight.w400,
            color: ThemeColor.color40,
          ),
          border: InputBorder.none,
        ),
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: ThemeColor.color40),
      ),
    );
  }

  Widget _buildItemBody(
      {String? title,
      bool isShowDivider = false,
      Widget? trailing,
      String? flag,
      GestureTapCallback? onTap,
      bool isShowArrow = true}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: Adapt.px(52),
            padding: EdgeInsets.symmetric(horizontal: Adapt.px(16)),
            child: Row(
              children: [
                Text(
                  title ?? '',
                  style: TextStyle(
                    color: ThemeColor.color0,
                    fontSize: Adapt.px(16),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: Adapt.px(122),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        trailing ??
                            SizedBox(
                              child: Text(
                                flag ?? '',
                                style: TextStyle(
                                  fontSize: Adapt.px(16),
                                  color: ThemeColor.color100,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                        isShowArrow
                            ? CommonImage(
                                iconName: 'icon_arrow_more.png',
                                width: Adapt.px(24),
                                height: Adapt.px(24),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: isShowDivider,
          child: Divider(
            height: Adapt.px(0.5),
            color: ThemeColor.color160,
          ),
        ),
      ],
    );
  }

  void _walletSelectorDialog() {
    final height = Adapt.px(56) * (_walletList.length + 1) + Adapt.px(8);
    final maxHeight = MediaQuery.of(context).size.height - Adapt.px(56) - MediaQuery.of(context).padding.top;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Material(
            type: MaterialType.transparency,
            child: Opacity(
              opacity: 1,
              child: Container(
                alignment: Alignment.topCenter,
                constraints: BoxConstraints(
                  maxHeight: height > maxHeight ? maxHeight : height,
                ),
                decoration: BoxDecoration(
                  color: ThemeColor.color180,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        // height: Adapt.px(280),
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: _itemWidget,
                          itemCount: _walletList.length,
                          shrinkWrap: true,
                        ),
                      ),
                      Container(
                        height: Adapt.px(8),
                        color: ThemeColor.color190,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          OXNavigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: Adapt.px(56),
                          color: ThemeColor.color180,
                          child: Center(
                            child: Text(
                              Localized.text('ox_common.cancel'),
                              style: TextStyle(
                                  fontSize: 16, color: ThemeColor.gray02),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  void _gotoScan() async {
    if (await Permission.camera.request().isGranted) {
      String? result =
      await OXNavigator.pushPage(context, (context) => CommonScanPage());
      if (result != null) {
        ScanUtils.analysis(context, result);
      }
    } else {
      OXCommonHintDialog.show(context,
          content: Localized.text('yl_home.str_permission_camera_hint'),
          actionList: [
            OXCommonHintAction(
                text: () => Localized.text('yl_home.str_go_to_settings'),
                onTap: () {
                  openAppSettings();
                  OXNavigator.pop(context);
                })
          ]);
    }
  }

  Widget _nwcItemWidget(BuildContext context, int index) {
    String walletName = 'Connect to Alby Wallet';
    if(index == 1) walletName = 'Scan QR Code';
    if(index == 2) walletName = 'Paste from Clipboard';
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        if(index == 0){
          OXNavigator.pop(context);
          OXModuleService.invoke('ox_common', 'gotoWebView', [context, 'https://nwc.getalby.com/', true, true, null, (url){
            if(url.startsWith('nostr+walletconnect://')) {
              ScanUtils.analysis(context!, url);
            }
          },]);
        }
        else if(index == 1){
          _gotoScan();
        }
        else if(index == 2){
          ClipboardData? data = await Clipboard.getData('text/plain');
          String? text;
          if (data != null) {
            text = data.text;
          }
          if(text?.startsWith('nostr+walletconnect://') == true) {
            ScanUtils.analysis(context, text!);
          }
          else{
            CommonToast.instance.show(
              context,
              Localized.text('ox_wallet.clipboard_no_content_tips'),
            );
          }
        }
      },
      child: Container(
        height: Adapt.px(56),
        alignment: Alignment.center,
        child: Text(
          walletName,
          style: TextStyle(fontSize: Adapt.px(16), color: ThemeColor.color0),
        ),
      ),
    );
  }

  Widget _nwcDisconnectWidget(BuildContext context, int index) {
    String disconnect = 'Disconnect wallet';
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        OXCommonHintDialog.show(context, showCancelButton: true, isRowAction: true,
            content: Localized.text('ox_usercenter.disconnect_wallet_warning'),
            actionList: [
              OXCommonHintAction(
                  text: () => Localized.text('ox_usercenter.disconnect_wallet_confirm'),
                  onTap: () {
                    OXNavigator.pop(context);
                    Zaps.sharedInstance.disconnectNWC();
                  })
            ]);
      },
      child: Container(
        height: Adapt.px(56),
        alignment: Alignment.center,
        child: Text(
          disconnect,
          style: TextStyle(fontSize: Adapt.px(16), color: ThemeColor.color0),
        ),
      ),
    );
  }

  void _nwcSelectorDialog() {
    final height = Adapt.px(56)*3 + Adapt.px(8);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Material(
            type: MaterialType.transparency,
            child: Opacity(
              opacity: 1,
              child: Container(
                alignment: Alignment.topCenter,
                height: Adapt.px(height),
                decoration: BoxDecoration(
                  color: ThemeColor.color180,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      // height: Adapt.px(280),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: _nwcItemWidget,
                        itemCount: 3,
                        shrinkWrap: true,
                      ),
                    ),
                    Container(
                      height: Adapt.px(8),
                      color: ThemeColor.color190,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        OXNavigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: Adapt.px(56),
                        color: ThemeColor.color180,
                        child: Center(
                          child: Text(
                            Localized.text('ox_common.cancel'),
                            style: TextStyle(
                                fontSize: 16, color: ThemeColor.gray02),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  void _nwcDisconnectDialog() {
    final height = Adapt.px(56)*2 + Adapt.px(8);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Material(
            type: MaterialType.transparency,
            child: Opacity(
              opacity: 1,
              child: Container(
                alignment: Alignment.topCenter,
                height: Adapt.px(height),
                decoration: BoxDecoration(
                  color: ThemeColor.color180,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      // height: Adapt.px(280),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: _nwcDisconnectWidget,
                        itemCount: 1,
                        shrinkWrap: true,
                      ),
                    ),
                    Container(
                      height: Adapt.px(8),
                      color: ThemeColor.color190,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        OXNavigator.pop(context);
                        setState(() async {
                          _selectedWalletName = UserConfigTool.getSetting(
                            StorageSettingKey.KEY_DEFAULT_WALLET.name,
                          );
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: Adapt.px(56),
                        color: ThemeColor.color180,
                        child: Center(
                          child: Text(
                            Localized.text('ox_common.cancel'),
                            style: TextStyle(
                                fontSize: 16, color: ThemeColor.gray02),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget _itemWidget(BuildContext context, int index) {
    String walletName = _walletList[index].title;
    String showName = walletName;
    if (walletName == 'NWC' && Account.sharedInstance.me?.nwcURI != null){
      showName = '$walletName (${Account.sharedInstance.me?.nwc?.lud16 ?? 'Connected'})';
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        OXNavigator.pop(context);
        if(walletName == 'NWC'){
          if(Account.sharedInstance.me?.nwcURI == null) {
            _nwcSelectorDialog();
          } else {
            _nwcDisconnectDialog();
          }
        }
        if (walletName != _selectedWalletName) {
          UserConfigTool.saveSetting(StorageSettingKey.KEY_DEFAULT_WALLET.name, walletName);
        }
        setState(() {
          _selectedWalletName = walletName;
        });
        widget.onChanged?.call(true);
      },
      child: Container(
        height: Adapt.px(56),
        alignment: Alignment.center,
        child: Text(
          showName,
          style: TextStyle(fontSize: Adapt.px(16), color: ThemeColor.color0),
        ),
      ),
    );
  }

  Widget _buildItemLabel({required String label}) {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: Adapt.px(16),
          color: ThemeColor.color0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildItem({required String label, required Widget itemBody}) {
    return Column(
      children: [
        _buildItemLabel(label: label),
        SizedBox(
          height: Adapt.px(12),
        ),
        itemBody,
        SizedBox(
          height: Adapt.px(12),
        ),
      ],
    );
  }

  Widget _buildWalletSelector() {
    return SizedBox(
      width: Adapt.px(36),
      height: Adapt.px(20),
      child: Switch(
        value: _walletSwitchSelected,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFFC084FC),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: ThemeColor.color160,
        onChanged: (value) async {
          if (!value) {
            if (_selectedWalletName ==
                Localized.text('ox_usercenter.not_set_wallet_status')) {
              CommonToast.instance.show(
                  context, Localized.text('ox_usercenter.not_set_wallet_tips'));
              return;
            }
          }

          setState(() {
            _walletSwitchSelected = value;
          });
          UserConfigTool.saveSetting(StorageSettingKey.KEY_IS_SHOW_WALLET_SELECTOR.name, value);
          widget.onChanged?.call(value);
        },
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  Widget _buildZapsRecord() {
    List<ZapsRecordDetail> zapsRecordDetails = _zapsRecord?.list ?? [];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(16)),
        color: ThemeColor.color180,
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 0),
        itemBuilder: (context, index) => _buildItemBody(
            title: '+${zapsRecordDetails[index].amount}',
            flag: zapsRecordDetails[index].zapsTimeFormat,
            onTap: () => OXNavigator.pushPage(
                context,
                (context) => ZapsRecordPage(
                      zapsRecordDetail: zapsRecordDetails[index],
                    ))),
        separatorBuilder: (context, index) => Divider(
          height: Adapt.px(0.5),
          color: ThemeColor.color160,
        ),
        itemCount: zapsRecordDetails.length,
        shrinkWrap: true,
      ),
    );
  }

  String _totalZaps(double totalZaps) {
    String result = '';

    if (totalZaps >= 210 && totalZaps < 2100) {
      result = '😊 ';
    } else if (totalZaps >= 2100 && totalZaps < 21000) {
      result = '🥰 ';
    } else if (totalZaps >= 21000 && totalZaps < 210000) {
      result = '😘 ';
    } else if (totalZaps >= 210000 && totalZaps < 2100000) {
      result = '❤️ ';
    } else if (totalZaps >= 2100000 && totalZaps < 21000000) {
      result = '🔥️';
    } else if (totalZaps >= 21000000) {
      result = '🚀️';
    }

    result = result + '$totalZaps';
    return result;
  }

  Future<ZapsRecord> getZapsRecord() async {
    String pubKey =
        OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey ?? '';
    await OXLoading.show();

    List<ZapRecordsDBISAR?> zapRecordsDBList = await Zaps.searchZapRecordsFromDB(recipient: pubKey, limit: 50);
    await OXLoading.dismiss();

    List<ZapsRecordDetail> zapsRecordDetailList = [];

    for (var zapRecordsDB in zapRecordsDBList) {
      if (zapRecordsDB != null) {
        final invoice = zapRecordsDB.bolt11;
        final fromPubKey = zapRecordsDB.sender;
        final toPubKey = zapRecordsDB.recipient;
        final paidAt = (zapRecordsDB.paidAt * 1000).toString();

        UserDBISAR? fromUser = await Account.sharedInstance.getUserInfo(fromPubKey);
        UserDBISAR? toUser = await Account.sharedInstance.getUserInfo(toPubKey);

        zapsRecordDetailList.add(
          ZapsRecordDetail(
              invoice: invoice,
              amount: Zaps.getPaymentRequestAmount(invoice),
              fromPubKey: '${fromUser?.name} (${fromUser?.shortEncodedPubkey})',
              toPubKey: '${toUser?.name} (${toUser?.shortEncodedPubkey})',
              zapsTime: paidAt,
              description: zapRecordsDB.content,
              isConfirmed: true),
        );
      }
    }

    ZapsRecord zapsRecord = ZapsRecord(
      list: zapsRecordDetailList,
    );

    return zapsRecord;
  }

  @override
  void dispose() {
    _zapAmountTextEditingController.dispose();
    _focusNode.dispose();
    _focusNode.removeListener(_amountFocusNoteListener);
    _zapDescriptionController.dispose();
    _descriptionFocusNote.dispose();
    _descriptionFocusNote.removeListener(_descriptionFocusNoteListener);
    super.dispose();
  }
}

class ZapsRecordRe {
  String id;
  int stats;
  String from;
  String to;
  DateTime time;
  String description;

  ZapsRecordRe(
      this.id, this.stats, this.from, this.to, this.time, this.description);
}
