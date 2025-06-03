import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_textfield.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_usercenter/model/database_set_model.dart';
import 'package:ox_usercenter/utils/widget_tool.dart';
import 'package:ox_usercenter/widget/database_item_widget.dart';
import 'package:chatcore/chat-core.dart';

///Title: database_passphrase
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2023/12/13 14:47
class DatabasePassphrase extends StatefulWidget {
  const DatabasePassphrase({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DatabasePassphraseState();
  }
}

class DatabasePassphraseState extends State<DatabasePassphrase> {
  final TextEditingController _currentTeController = TextEditingController();
  final TextEditingController _newTeController = TextEditingController();
  final TextEditingController _confirmTeController = TextEditingController();
  final FocusNode _currentFocusNode = FocusNode();
  final FocusNode _newFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();
  bool _currentEyeStatus = true;
  bool _newEyeStatus = true;
  bool _confirmEyeStatus = true;
  String pubkey = '';
  String currentDBPW = '';
  double _opacityUpdate = 0.5;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    pubkey = OXUserInfoManager.sharedInstance.currentUserInfo?.pubKey ?? '';
    currentDBPW = await OXCacheManager.defaultOXCacheManager.getForeverData('dbpwisar+$pubkey', defaultValue: '');
    _currentTeController.text = currentDBPW;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        centerTitle: true,
        useLargeTitle: false,
        title: 'str_database_passphrase'.localized(),
      ),
      backgroundColor: ThemeColor.color190,
      body: _body(),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          if (currentDBPW.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                await TookKit.copyKey(context, currentDBPW);
              },
              child: CommonTextField(
                controller: _currentTeController,
                inputEnabled: false,
                type: TextFieldType.normal,
                keyboardType: TextInputType.visiblePassword,
                needTopView: true,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                focusNode: _currentFocusNode,
                decoration: _getInputDecoration('str_current_passphrase'.localized()),
                obscureText: _currentEyeStatus,
                leftWidget: _getLeftWidget(_currentEyeStatus, PassphraseEyeType.currentPassphrase),
              ),
            ),
          CommonTextField(
            controller: _newTeController,
            type: TextFieldType.normal,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            focusNode: _newFocusNode,
            decoration: _getInputDecoration('str_new_passphrase'.localized()),
            leftWidget: _getLeftWidget(_newEyeStatus, PassphraseEyeType.newPassphrase),
            obscureText: _newEyeStatus,
            onChanged: (String value) {
              _checkNewPW();
            },
          ),
          CommonTextField(
            controller: _confirmTeController,
            type: TextFieldType.normal,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            focusNode: _confirmFocusNode,
            decoration: _getInputDecoration('str_confirm_new_passphrase'.localized()),
            leftWidget: _getLeftWidget(_confirmEyeStatus, PassphraseEyeType.confirmPassPhrase),
            obscureText: _confirmEyeStatus,
            onChanged: (String value) {
              _checkNewPW();
            },
          ),
          SizedBox(height: 12.px),
          Opacity(
            opacity: _opacityUpdate,
            child: DatabaseItemWidget(
              height: 48.px,
              title: 'str_update_database_passphrase',
              titleTxtColor: _opacityUpdate == 1.0 ? ThemeColor.color0 : ThemeColor.color100,
              radiusCornerList: [16.px, 16.px, 16.px, 16.px],
              iconRightMargin: 8,
              iconName: 'icon_update.png',
              iconSize: 24.px,
              iconPackage: 'ox_common',
              onTapCall: _confirmUpdateDialog,
            ),
          ),
          SizedBox(height: 12.px),
          abbrText('str_passphrase_hint'.localized(), 12, ThemeColor.color100),
        ],
      ).setPadding(EdgeInsets.symmetric(horizontal: 24.px, vertical: 12.px)),
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 16.px,
        color: ThemeColor.color100,
      ),
      contentPadding: EdgeInsets.only(left: 8.px),
      border: InputBorder.none,
    );
  }

  Widget _getLeftWidget(bool eysStatus, PassphraseEyeType eyeType) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        switch (eyeType) {
          case PassphraseEyeType.currentPassphrase:
            _currentEyeStatus = !_currentEyeStatus;
            break;
          case PassphraseEyeType.newPassphrase:
            _newEyeStatus = !_newEyeStatus;
            break;
          case PassphraseEyeType.confirmPassPhrase:
            _confirmEyeStatus = !_confirmEyeStatus;
            break;
        }
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.only(left: 16.px),
        child: CommonImage(
          iconName: eysStatus ? 'icon_obscure_close.png' : 'icon_obscure.png',
          width: 24.px,
          height: 24.px,
        ),
      ),
    );
  }

  void _checkNewPW() {
    String newPW = _newTeController.text.isEmpty ? '' : _newTeController.text;
    String confirmPW = _confirmTeController.text.isEmpty ? '' : _confirmTeController.text;
    if (newPW == confirmPW) {
      _opacityUpdate = 1;
    } else {
      _opacityUpdate = 0.5;
    }
    setState(() {});
  }

  void _confirmUpdateDialog(){
    if (_opacityUpdate == 0.5) return;
    OXCommonHintDialog.show(
      context,
      title: 'str_change_database_passphrase_title'.localized(),
      content: 'str_change_database_passphrase_hint'.localized(),
      isRowAction: true,
      actionList: [
        OXCommonHintAction(
            text: () => Localized.text('ox_common.cancel'),
            onTap: () {
              OXNavigator.pop(context);
            }),
        OXCommonHintAction(
            text: () => 'str_update_database_pw'.localized(),
            onTap: () {
              OXNavigator.pop(context);
              _clickUpdatePassphrase();
            }),
      ],
    );
  }

  void _clickUpdatePassphrase() async {
    String tempCurrentPW = _currentTeController.text.isEmpty ? '' : _currentTeController.text;
    if (currentDBPW != tempCurrentPW) {
      OXCommonHintDialog.showConfirmDialog(context,
          title: 'str_passphrase_current_error_title'.localized(),
          content: 'str_passphrase_current_error'.localized()
      );
      return;
    }
    await keychainWrite();
  }

  Future<void> keychainWrite() async {
    String confirmPW = _confirmTeController.text.isEmpty ? '' : _confirmTeController.text;
    try {
      await OXCacheManager.defaultOXCacheManager.saveForeverData('dbpwisar+$pubkey', confirmPW);
      CommonToast.instance.show(context, 'str_update_pw_success'.localized());
      await changeDatabasePassword(currentDBPW, confirmPW);
    } catch (e) {
      print(e.toString());
    }
    OXNavigator.pop(context);
  }

  Future<void> changeDatabasePassword(String currentPassword, String newPassword) async {
    await DB.sharedInstance.execute("PRAGMA rekey = '$newPassword'");
    await DB.sharedInstance.closDatabase();
    // await DB.sharedInstance.open(pubkey + ".db2", version: CommonConstant.dbVersion, password: newPassword, pubkey: pubkey);
  }

}
