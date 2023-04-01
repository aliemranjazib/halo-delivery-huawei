import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/remarks_textbox.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/cancel_reason_model.dart';
import 'package:haloapp/networkings/history_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class DeliveryCancelBookingDialog extends StatefulWidget {
  final String bookingUniqueKey;

  DeliveryCancelBookingDialog({@required this.bookingUniqueKey});

  @override
  _DeliveryCancelBookingDialogState createState() =>
      _DeliveryCancelBookingDialogState();
}

class _DeliveryCancelBookingDialogState
    extends State<DeliveryCancelBookingDialog> {
  bool _showSpinner = false;
  // List<CancelReasonModel> _cancellationReasons = [
  //   CancelReasonModel(
  //       name: 'My order is taking longer than expected',
  //       nameLocalizedKey: 'my_order_is_taking_longer_than_expected'),
  //   CancelReasonModel(
  //       name: 'I accidentally placed the order',
  //       nameLocalizedKey: 'i_accidentally_placed_the_order'),
  //   CancelReasonModel(
  //       name: 'My promo code wasn\'t applied to my order',
  //       nameLocalizedKey: 'my_promo_code_wasnt_applied_to_my_order'),
  //   CancelReasonModel(
  //       name: 'I changed my mind', nameLocalizedKey: 'i_changed_my_mind'),
  //   CancelReasonModel(
  //       name: 'This is a duplicate order',
  //       nameLocalizedKey: 'this_is_a_duplicate_order'),
  //   CancelReasonModel(name: 'Others', nameLocalizedKey: 'others'),
  // ];

  List<CancelRemark> _cancellationReasons = AppConfig.cancelRemarks;
  CancelRemark _selectedReason;
  String _remarkTFValue;

  void cancelBooking() async {
    if (_selectedReason == null) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_select_a_cancellation_reason'),
          context);
      return;
    }

    if (_selectedReason.value == 'Others' &&
        (_remarkTFValue == null || _remarkTFValue.isEmpty)) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_write_your_cancellation_remark'),
          context);
      return;
    }

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {
        "bookingUniqueKey": widget.bookingUniqueKey,
        "cancelRemark": (_selectedReason.value == "Others")
            ? _remarkTFValue
            : _selectedReason.value
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await HistoryNetworking().cancelBooking(params);

      Navigator.pop(context, data);
    } catch (e) {
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          Navigator.pop(
            context,
            PopWithResults(
              fromPage: 'cancelBooking',
              toPage: 'login',
              results: {
                'logout': true,
                'msg': e,
              },
            ),
          );
        }
      } else {
        print(e.toString());
        showSimpleFlushBar(e, context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Center(
        child: SingleChildScrollView(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Image.asset("images/ic_notice.png",width: 30.0,height: 30.0,),
                            SizedBox(width: 3.0,),
                            Text(
                              AppTranslations.of(context).text('cancel_booking'),
                              textAlign: TextAlign.center,
                              style: kTitleTextStyle,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Image.asset("images/ic_cancel.png",width: 30.0,height: 30.0,)
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    AppTranslations.of(context)
                        .text('select_booking_cancellation_reason'),
                    style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                  ),
                  SizedBox(height: 15.0),
                  InputDecorator(
                    decoration: InputDecoration(
                      hintText:
                          AppTranslations.of(context).text('cancellation_reason'),
                      border: kOutlineInputBorder,
                      enabledBorder: kOutlineInputBorder,
                      focusedBorder: kOutlineInputBorderActive,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text(
                          _selectedReason == null
                              ? AppTranslations.of(context)
                                  .text('cancellation_reason')
                              : AppTranslations.of(context)
                                  .text(_selectedReason.title),
                          overflow: TextOverflow.clip,
                        ),
                        value: _selectedReason,
                        isDense: true,
                        isExpanded: true,
                        items: _cancellationReasons.map((CancelRemark reason) {
                          return DropdownMenuItem<CancelRemark>(
                            value: reason,
                            child: Text(AppTranslations.of(context)
                                .text(reason.title)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedReason = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  (_selectedReason != null && _selectedReason.value == 'Others')
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              AppTranslations.of(context)
                                  .text('your_remark_mandatory'),
                              style: TextStyle(
                                  fontFamily: poppinsRegular, fontSize: 16),
                            ),
                            SizedBox(height: 10.0),
                            RemarksTextBox(
                              hintText: AppTranslations.of(context)
                                  .text('write_your_remark_here'),
                              onChanged: (value) {
                                _remarkTFValue = value;
                              },
                            )
                          ],
                        )
                      : Container(),
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
                          buttonText: AppTranslations.of(context).text('submit'),
                          onPressed: () {
                            cancelBooking();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
