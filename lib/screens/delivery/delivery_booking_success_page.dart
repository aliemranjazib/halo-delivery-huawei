import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components_new/address_icon.dart';
import 'package:haloapp/components_new/address_otw_icon.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'dart:math' as math;

class DeliveryBookingSuccessPage extends StatefulWidget {
  @override
  _DeliveryBookingSuccessPageState createState() =>
      _DeliveryBookingSuccessPageState();
}

class _DeliveryBookingSuccessPageState
    extends State<DeliveryBookingSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () {
              BookingModel().clearBookingData();
              Navigator.pop(context, 'close');
            },
          ),
          actions: <Widget>[
            // Padding(
            //   padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
            //   child: GestureDetector(
            //     onTap: () {
            //       BookingModel().clearBookingData();
            //       Navigator.pop(context, 'close');
            //     },
            //     child: Container(
            //       height: 30,
            //       width: 30,
            //       margin: EdgeInsets.only(right: 20.0),
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(5.0),
            //         color: Colors.grey.withOpacity(0.7),
            //       ),
            //       child: Icon(
            //         Icons.close,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Text(
                        //   AppTranslations.of(context)
                        //       .text('successfully_made_the_booking'),
                        //   style: kTitleTextStyle,
                        // ),
                        // SizedBox(height: 40.0),
                        Image.asset('images/ic_waiting.png',width: 250.0,height: 250.0,),
                        SizedBox(height: 20.0),
                        Text(
                          AppTranslations.of(context).text("assign_driver"),
                          style: kTitleLargeBoldTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.0),
                        renderDeliveryDetails(),
                        // Text(
                        //   AppTranslations.of(context)
                        //       .text('pickup_date_n_time'),
                        //   style: kDetailsTextStyle,
                        // ),
                        // SizedBox(height: 10.0),
                        // Text(
                        //   BookingModel().getPickupDate() +
                        //       ' ' +
                        //       BookingModel().getPickupTime(),
                        //   style: kDetailsTextStyle,
                        // ),
                        SizedBox(height: 20.0),
                        ActionButton(
                            onPressed: () {
                              BookingModel().clearBookingData();
                              Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));

                              // Navigator.pop(context, 'close');
                            },
                            buttonText: AppTranslations.of(context)
                                .text('back_to_home_page'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  renderDeliveryDetails() {
    return Container(
      padding: EdgeInsets.only(left: 12.0,right: 12.0,top: 6.0,bottom: 6.0),
      decoration:BoxDecoration(
        color: light3Grey,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [elevation]
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.of(context).text("delivery_details"),
            style: kDetailsSemiBoldTextStyle,
          ),
          SizedBox(height: 6.0,),
          Row(
            children: [
              Image.asset("images/ic_clock.png",width: 30.0,height: 30.0,),
              Text(
                BookingModel().getPickupDate() + ' ' + BookingModel().getPickupTime(),
                style: kDetailsSemiBoldTextStyle,
              ),
            ],
          ),
          Container(
            height: 1,
            color: lightGrey,
            margin: EdgeInsets.symmetric(vertical: 10.0),
          ),
          ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: BookingModel().getAllAddresses().length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                color: lightGrey,
                indent: 16,
                endIndent: 16,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return Row(
                crossAxisAlignment: getAlign(index),
                children: [
                  if (index == 0) AddressIcon(),
                  if (index == BookingModel().getAllAddresses().length - 1)
                    Transform.rotate(
                      angle: 180 * math.pi / 180,
                      child: AddressIcon(),
                    ),
                  if (index != BookingModel().getAllAddresses().length - 1 && index != 0) AddressOTWIcon(),
                  // if (index != stops.length - 1 && index != 0)
                  //   SizedBox(width: 10.0),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      child: renderAddressText(index),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  CrossAxisAlignment getAlign(int index){
    if(index == 0){
      return CrossAxisAlignment.end;
    }else if(index == BookingModel().getAllAddresses().length - 1){
      return CrossAxisAlignment.start;
    }else{
      return CrossAxisAlignment.center;
    }
  }

  Widget renderAddressText(int index) {
    if (BookingModel().getAllAddresses() != null &&
        BookingModel().getAllAddresses().length > index &&
        BookingModel().getAddressAtIndex(index) != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${BookingModel().getAddressAtIndex(index).receiverName} | ${BookingModel().getAddressAtIndex(index).receiverPhone}",
            style: kAddressTextStyle.copyWith(
                color: darkGrey
            ),
          ),
          Text(
            BookingModel().getAddressAtIndex(index).fullAddress,
            style: kAddressTextStyle,
          )
        ],
      );
    }
    return Container();
  }
}
