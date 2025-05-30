import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_localizable/ox_localizable.dart';

class KeysPage extends StatefulWidget {

  const KeysPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<StatefulWidget> createState() {
    return _KeysPageState();
  }

}
enum KeyType { PublicKey, PrivateKey }
class _KeysPageState extends State<KeysPage>{

  ValueNotifier<bool> isShowPriv$ = ValueNotifier(false);

  String encodedPubkey = '';
  String encodedPrivkey = '';

  @override
  void initState() {
    super.initState();

    encodedPubkey = OXUserInfoManager.sharedInstance.currentUserInfo?.encodedPubkey ?? '';
    encodedPrivkey = OXUserInfoManager.sharedInstance.currentUserInfo?.encodedPrivkey ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_usercenter.keys'),
        previousPageTitle: widget.previousPageTitle,
      ),
      isSectionListPage: true,
      body: _body(),
    );
  }

  Widget _body() {
    return ValueListenableBuilder(
      valueListenable: isShowPriv$,
      builder: (context, isShowPriv, _) {
        return CLSectionListView(
          items: [
            SectionListViewItem(
              data: [
                CustomItemModel(
                  title: Localized.text('ox_login.public_key'),
                  subtitleWidget: CLText(
                    encodedPubkey,
                    maxLines: 2,
                  ),
                  trailing: Icon(
                    Icons.copy_rounded,
                    color: ColorToken.onSecondaryContainer.of(context),
                  ),
                  onTap: pubkeyItemOnTap,
                ),
                CustomItemModel(
                  title: Localized.text('ox_login.private_key'),
                  subtitleWidget: CLText(
                    isShowPriv ? encodedPrivkey
                        : List.filled(encodedPrivkey.length, '*').join(),
                    maxLines: 2,
                  ),
                  trailing: Icon(
                    Icons.copy_rounded,
                    color: ColorToken.onSecondaryContainer.of(context),
                  ),
                  onTap: privkeyItemOnTap,
                ),
              ],
            ),
          ],
          footer: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.px),
            child: buildShowButton(),
          ),
        );
      },
    );
  }

  Widget buildShowButton() {
    return CLButton.tonal(
      minimumSize: Size(90.px, 48.px),
      padding: EdgeInsets.symmetric(
        horizontal: 12.px,
        vertical: 12.px,
      ),
      text: 'Show Private Key',
      onTap: () => isShowPriv$.value = true,
    );
  }

  void pubkeyItemOnTap () async {
    await TookKit.copyKey(
      context,
      encodedPubkey,
    );
  }

  void privkeyItemOnTap() async {
    await TookKit.copyKey(
      context,
      encodedPrivkey,
    );
  }
}