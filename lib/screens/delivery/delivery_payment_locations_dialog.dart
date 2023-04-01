import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';

class DeliveryPaymentLocationsDialog extends StatefulWidget {
  @override
  _DeliveryPaymentLocationsDialogState createState() =>
      _DeliveryPaymentLocationsDialogState();
}

class _DeliveryPaymentLocationsDialogState
    extends State<DeliveryPaymentLocationsDialog> {
  String _selectedAddressId = '';

  @override
  void initState() {
    super.initState();

    if (BookingModel().getSelectedAddressIdToCollectPayment() != null &&
        BookingModel().getSelectedAddressIdToCollectPayment() != '') {
      _selectedAddressId =
          BookingModel().getSelectedAddressIdToCollectPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppTranslations.of(context).text('select_payment_location'),
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            SizedBox(height: 20.0),
            Container(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom) /
                  2,
              child: SingleChildScrollView(
                  child: addressesList(BookingModel().getAllAddresses())),
            ),
            SizedBox(height: 40.0),
            ActionButton(
              buttonText: AppTranslations.of(context).text('confirm'),
              onPressed: () {
                Navigator.pop(context, _selectedAddressId);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget addressesList(List<AddressModel> addresses) {
    List<Widget> list = [];

    for (int i = 0; i < addresses.length; i++) {
      AddressModel address = addresses[i];

      Widget radioBtn = ListTile(
        contentPadding: EdgeInsets.all(0),
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedAddressId = address.addressId;
            });
          },
          child: Text(
            address.fullAddress,
            style: kDetailsTextStyle,
          ),
        ),
        leading: Radio(
          fillColor: MaterialStateColor.resolveWith((states) => kColorRed),
          value: address.addressId,
          groupValue: _selectedAddressId,
          onChanged: (value) {
            setState(() {
              _selectedAddressId = value;
            });
          },
        ),
      );

      list.add(radioBtn);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }
}
