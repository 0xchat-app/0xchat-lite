import 'package:flutter/material.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/theme_button.dart';
import 'package:ox_wallet/widget/ecash_common_button.dart';

class WalletSuccessfulPage extends StatelessWidget {
  final String title;
  final Widget? action;
  final String? tips;
  final String? content;
  final Widget? bottomWidget;
  final bool canBack;
  const WalletSuccessfulPage({super.key, required this.title, this.action, this.tips, this.content, this.bottomWidget, bool? canBack}) : canBack = canBack ?? true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.color190,
      appBar: CommonAppBar(
        title: title,
        centerTitle: true,
        useLargeTitle: false,
        canBack: canBack,
        leading: !canBack ? Container() : null,
        actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.px),
              child: action ?? Container(),
            ),
          ],
        ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBody(),
            _buildBottomWidget(context),
          ],
        ),
      )
    );
  }

  Widget _buildBody(){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonImage(
            iconName: 'icon_successful.png',
            size: 112.px,
            package: 'ox_wallet',
          ),
          SizedBox(height: 24.px,),
          Text(
            tips ?? 'Success',
            style: TextStyle(
                fontSize: 26.px,
                fontWeight: FontWeight.w600,
                color: ThemeColor.color0),
          ),
          SizedBox(height: 8.px,),
          Text(
            content ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.px,
              fontWeight: FontWeight.w400,
              color: ThemeColor.color100,
              height: 20.px / 14.px,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    return Container(
      child: bottomWidget ?? EcashCommonButton(text: 'Close', onTap: () => OXNavigator.pop(context)),
    ).setPaddingOnly(bottom: 16.px, left: 24.px, right: 24.px);
  }

  factory WalletSuccessfulPage.invoicePaid({required String amount, GestureTapCallback? onTap}) {
    return WalletSuccessfulPage(
      title: 'Receive',
      tips: 'Invoice Paid',
      content: '$amount sats was added your Lightning account.',
      bottomWidget: ThemeButton(
        text: 'Receive another payment',
        height: 48.px,
        onTap: onTap,
      ),
    );
  }

  factory WalletSuccessfulPage.redeemClaimed({required String amount,String? content, GestureTapCallback? onTap}){
    return WalletSuccessfulPage(
      title: 'Redeem Ecash',
      tips: '$amount Sats Claimed!',
      content: content,
      canBack: false,
      bottomWidget: EcashCommonButton(text: 'Back to dashboard', onTap: onTap),
    );
  }
}
