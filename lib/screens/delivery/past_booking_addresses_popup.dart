import 'package:flutter/material.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class PastBookingAddressesDialog extends StatefulWidget {
  PastBookingAddressesDialog({@required this.addresses});

  final List<AddressModel> addresses;

  @override
  _PastBookingAddressesDialogState createState() =>
      _PastBookingAddressesDialogState();
}

class _PastBookingAddressesDialogState
    extends State<PastBookingAddressesDialog> {
  List<Widget> _buildAddressesView() {
    List<AddressModel> addresses = widget.addresses;
    List<Widget> addressesView = [];

    if (addresses.length > 0) {
      for (int i = 0; i < addresses.length; i++) {
        AddressModel address = addresses[i];

        Widget addressView = GestureDetector(
          onTap: () {
            Navigator.pop(context, address);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                (address.type == 'pickup')
                    ? 'images/pin_blue.png'
                    : 'images/pin_red.png',
                height: 20,
              ),
              SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  address.fullAddress,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
                ),
              )
            ],
          ),
        );

        addressesView.add(addressView);

        if (i < addresses.length - 1) {
          addressesView.add(Divider(
            height: 20.0,
            color: Colors.grey,
          ));
        }
      }
    }

    return addressesView;
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
              AppTranslations.of(context).text('past_bookings_addresses'),
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            SizedBox(height: 15.0),
            Text(
              AppTranslations.of(context).text(
                  'addresses_below_are_from_your_past_bookings_select_or_type_new_one'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: poppinsItalic, fontSize: 14),
            ),
            SizedBox(height: 25.0),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, 'newAddress');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.edit,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    AppTranslations.of(context).text('type_a_new_address'),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: poppinsRegular,
                        fontSize: 14,
                        color: Colors.grey),
                  )
                ],
              ),
            ),
            Divider(
              height: 20.0,
              color: Colors.grey,
            ),
            Container(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom) /
                  2,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildAddressesView(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
