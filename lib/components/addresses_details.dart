import 'package:flutter/material.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class AddressesDetails extends StatefulWidget {
  const AddressesDetails({
    Key key,
    @required this.addresses,
    @required this.showPayment,
    this.onlinePayment = false,
  }) : super(key: key);

  final List<AddressModel> addresses;
  final bool showPayment;
  final bool onlinePayment;

  @override
  _AddressesDetailsState createState() => _AddressesDetailsState();
}

class _AddressesDetailsState extends State<AddressesDetails> {
  List<Widget> addressesView() {
    List<AddressModel> addresses = widget.addresses;
    List<Widget> addressesView = [];

    if (addresses.length > 0) {
      for (int i = 0; i < addresses.length; i++) {
        AddressModel address = addresses[i];

        Widget addressView = Row(
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
        );

        addressesView.add(addressView);

        addressesView.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 10.0),
              Text(
                '${AppTranslations.of(context).text('unit_no')}: ${(address.unitNo != '') ? address.unitNo : '-'}',
                style: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
              ),
              Text(
                  '${AppTranslations.of(context).text('building_name')}: ${(address.buildingName != '') ? address.buildingName : '-'}',
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 14)),
              Text(
                  '${AppTranslations.of(context).text('recipient_name')}: ${(address.receiverName != '') ? address.receiverName : '-'}',
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 14)),
              Text(
                  '${AppTranslations.of(context).text('recipient_contact_no')}: ${(address.receiverPhone != '') ? address.receiverPhone : '-'}',
                  style: TextStyle(fontFamily: poppinsRegular, fontSize: 14))
            ],
          ),
        ));

        if (address.paymentCollect &&
            widget.showPayment &&
            !widget.onlinePayment) {
          addressesView.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppTranslations.of(context)
                  .text('rider_will_collect_payment_at_this_location'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: poppinsMedium, fontSize: 14, color: Colors.green),
            ),
          ));
        }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: addressesView(),
    );
  }
}
