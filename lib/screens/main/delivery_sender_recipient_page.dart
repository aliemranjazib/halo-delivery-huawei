import 'package:flutter/material.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class DeliverySenderRecipientPage extends StatefulWidget {
  static const String id = 'DeliverySenderRecipientPage';

  @override
  _DeliverySenderRecipientPageState createState() =>
      _DeliverySenderRecipientPageState();
}

class _DeliverySenderRecipientPageState
    extends State<DeliverySenderRecipientPage> {
  final _senderFormKey = GlobalKey<FormState>();
  final _recipientFormKey = GlobalKey<FormState>();

  renderInputForm(GlobalKey key) {
    return Form(
      key: key,
      child: Column(
        children: [
          InputTextFormField(
            hintText: AppTranslations.of(context).text('sender_name'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTranslations.of(context).text('sender_receiver'),
              style: kAppBarTextStyle.copyWith(
                fontSize: 14,
                fontFamily: poppinsSemiBold,
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/ic_sender.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    AppTranslations.of(context).text('sender_information'),
                    style: TextStyle(
                      fontFamily: poppinsMedium,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              renderInputForm(_senderFormKey),
            ],
          ),
        ),
      ),
    );
  }
}
