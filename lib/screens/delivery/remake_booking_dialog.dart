import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/addresses_details.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/styles.dart';

class RemakeSameBookingConfirmationDialog extends StatefulWidget {
  RemakeSameBookingConfirmationDialog({@required this.addresses});

  final List<AddressModel> addresses;

  @override
  _RemakeSameBookingConfirmationDialogState createState() =>
      _RemakeSameBookingConfirmationDialogState();
}

class _RemakeSameBookingConfirmationDialogState
    extends State<RemakeSameBookingConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppTranslations.of(context).text('make_new_booking'),
                textAlign: TextAlign.center,
                style: kTitleTextStyle,
              ),
              SizedBox(height: 20.0),
              Text(
                AppTranslations.of(context).text(
                    'are_you_sure_to_make_the_new_booking_with_the_same_info_below'),
                textAlign: TextAlign.center,
                style: kDetailsTextStyle,
              ),
              SizedBox(height: 20.0),
              Container(
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom) /
                    2,
                child: SingleChildScrollView(
                  child: AddressesDetails(
                      addresses: widget.addresses, showPayment: false),
                ),
              ),
              SizedBox(height: 40.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ActionButtonLight(
                      buttonText: AppTranslations.of(context).text('cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: ActionButton(
                      buttonText: AppTranslations.of(context).text('confirm'),
                      onPressed: () {
                        Navigator.pop(context, 'confirm');
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
