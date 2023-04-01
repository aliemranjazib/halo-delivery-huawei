import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/styles.dart';

class OnlinePaymentPage extends StatefulWidget {
  static const String id = 'onlinePaymentPage';
  final String paymentLink;

  OnlinePaymentPage({this.paymentLink});

  @override
  _OnlinePaymentPageState createState() => _OnlinePaymentPageState();
}

class _OnlinePaymentPageState extends State<OnlinePaymentPage> {
  InAppWebViewController webView;
  double progress = 0;

  _confirmQuitPaymentDialog() {
    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('quit_payment_ques'),
              message: AppTranslations.of(context)
                  .text('are_you_sure_to_quit_this_page'),
            )).then((value) {
      if (value != null && value == 'confirm') {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _confirmQuitPaymentDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppTranslations.of(context).text('online_payment'),
              style: kAppBarTextStyle),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: <Widget>[
                Row() ??
                    Container(
                        child: progress < 1.0
                            ? LinearProgressIndicator(value: progress)
                            : Container()),
                Expanded(
                  child: Container(
                    child: InAppWebView(
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            // useShouldOverrideUrlLoading: true,
                            mediaPlaybackRequiresUserGesture: false,
                          ),
                          android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                          ),
                          ios: IOSInAppWebViewOptions(
                            allowsInlineMediaPlayback: true,
                          )),
                      initialUrlRequest:
                          URLRequest(url: Uri.parse(widget.paymentLink)),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webView = controller;
                      },
                      onLoadStart: (controller, url) {
//                        print('onLoadStart: $url');
                      },
                      onLoadStop: (controller, url) async {
                        print('onLoadStop: $url');

                        String lastParamInUrl = url.toString().split('/').last;

                        if (lastParamInUrl == 'return') {
                          Navigator.pop(context, 'onlinePaymentSuccess');
                        }
                      },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {
                        //     if(progress != this.progress)
                        // setState(() {
                        //   this.progress = progress / 100;
                        // });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
