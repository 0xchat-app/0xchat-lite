import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_wallet/utils/wallet_utils.dart';
import 'package:ox_wallet/widget/common_card.dart';
import 'package:ox_wallet/widget/ecash_qr_code.dart';
import 'package:ox_wallet/widget/screenshot_widget.dart';

class BTCReceivePage extends StatefulWidget {
  final ValueNotifier<bool>? shareController;
  const BTCReceivePage({super.key, this.shareController});

  @override
  State<BTCReceivePage> createState() => _BTCReceivePageState();
}

class _BTCReceivePageState extends State<BTCReceivePage> {

  final ValueNotifier<String?> _invoiceNotifier = ValueNotifier('');
  final String tips = '• Do not send Ordinals or any inscriptions to this address\r\n• Do not send more than 0.05BTC to this address';
  final _btcReceivePageScreenshotKey = GlobalKey<ScreenshotWidgetState>();

  @override
  void initState() {
    _createLightningInvoice();
    widget.shareController?.addListener(() {
      WalletUtils.takeScreen(_btcReceivePageScreenshotKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildReceiveInfo(),
            ],
          ).setPadding(EdgeInsets.symmetric(horizontal: 24.px)),
        ),
      ],
    );
  }

  Widget _buildReceiveInfo(){
    return ValueListenableBuilder(
        valueListenable: _invoiceNotifier,
        builder: (context,value,child) {
          return CommonCard(
            verticalPadding: 24.px,
            height: 386.px,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('bc1qw2cwz63l6a8jasgy2l2ruth0pmt4dah8fda6fv',),
                SizedBox(height: 16.px,),
                ScreenshotWidget(key:_btcReceivePageScreenshotKey, child: EcashQrCode(controller: _invoiceNotifier,)),
                SizedBox(height: 16.px,),
                Text(tips,style: TextStyle(color: ThemeColor.red1,fontSize: 12.px,height: 20.px / 12.px),),
              ],
            ),
          );
        }
    );
  }

  Future<void> _createLightningInvoice() async {
    Future.delayed(const Duration(seconds: 5),()=> _invoiceNotifier.value = null);
  }
}