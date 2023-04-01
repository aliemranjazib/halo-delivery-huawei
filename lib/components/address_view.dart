import 'package:flutter/material.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import '../models/booking_model.dart';
import '../utils/constants/styles.dart';

class AddressView extends StatefulWidget {
  final int addressIndex;
  final int textMaxLines;

  AddressView({@required this.addressIndex, this.textMaxLines});

  @override
  _AddressViewState createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  Widget titleText() {
    String title = 'enter_address_details';
    TextStyle style = kAddressPlaceholderTextStyle;
    double iconHeight = 20.0;
    Image icon = Image.asset('images/pin_white.png', height: iconHeight);

    if (BookingModel().getAllAddresses() != null &&
        BookingModel().getAllAddresses().length > widget.addressIndex &&
        BookingModel().getAddressAtIndex(widget.addressIndex) != null) {
      title = BookingModel().getAddressAtIndex(widget.addressIndex).fullAddress;
      style = kAddressTextStyle;

      if (widget.addressIndex == 0) {
        icon = Image.asset('images/pin_blue.png', height: iconHeight);
      } else {
        icon = Image.asset('images/pin_red.png', height: iconHeight);
      }
    } else {
      if (widget.addressIndex == 0) {
        title = 'enter_pickup_details';
      } else if (widget.addressIndex == 1) {
        title = 'enter_deliver_details';
      }
      style = kAddressPlaceholderTextStyle;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        icon,
        SizedBox(width: 8.0),
        Flexible(
          child: Text(
            AppTranslations.of(context).text(title),
            style: style,
            maxLines: widget.textMaxLines,
            overflow: (widget.textMaxLines == 1)
                ? TextOverflow.ellipsis
                : TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      color: Colors.white,
      child: titleText(),
    );
  }
}
