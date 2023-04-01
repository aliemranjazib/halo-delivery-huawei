import 'package:flutter/material.dart';
import 'package:haloapp/components_new/address_icon.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'dart:math' as math;

import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class AddressDetail extends StatelessWidget {
  AddressDetail({
    this.addresses,
    this.selectedId,
    this.showContact = false,
  });

  final List<AddressModel> addresses;
  final String selectedId;
  final bool showContact;

  renderAddresses(BuildContext context) {
    List<Widget> addressesView = [];

    if (addresses != null) {
      for (int i = 0; i < addresses.length; i++) {
        AddressModel address = addresses[i];

        Widget view = Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(address.receiverName != null && address.receiverName != '') ? address.receiverName : ''} ${showContact? " - ${address.receiverPhone}":""}',
                overflow: TextOverflow.ellipsis,
                style: kAddressPlaceholderTextStyle.copyWith(fontSize: 14),
              ),
              Text(
                address.fullAddress,
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
                style: TextStyle(
                  fontFamily: poppinsSemiBold,
                  fontSize: 14,
                ),
              ),
              if(selectedId!=null && selectedId == address.addressId)
              Row(
                children: [
                  Image.asset("images/ic_green_tick.png",width: 25.0,height: 25.0,),
                  SizedBox(width: 3.0,),
                  Flexible(
                    child: Text(
                      '${AppTranslations.of(context).text('rider_will_collect_payment_at_this_address')}',
                      style: TextStyle(
                        fontFamily: poppinsMedium,
                        color: Colors.green,
                      ),
                    )
                  )
                ],
              )
            ],
          ),
        );

        if (i == 1) {
          addressesView.add(Divider());
        }

        addressesView.add(view);
      }

      return addressesView;
    }

    return addressesView;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [
              AddressIcon(),
              Transform.rotate(
                angle: 180 * math.pi / 180,
                child: AddressIcon(),
              ),
            ],
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: renderAddresses(context),
            ),
          )
        ],
      ),
    );
  }
}
