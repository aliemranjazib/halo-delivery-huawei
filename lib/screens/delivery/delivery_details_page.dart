import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/cupertino_datetime_picker_popup.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'dart:io' show Platform;
import 'package:haloapp/components/remarks_textbox.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/item_type_model.dart';
import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/screens/delivery/delivery_review_page.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/general/upload_image_popup.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as Img;

import 'package:haloapp/components/model_progress_hud.dart';

class DeliveryDetailsPage extends StatefulWidget {
  static const String id = 'deliveryDetailsPage';

  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  bool _showSpinner = false;
  String _encodedImage;
  String _uploadedImageUrl;
  String _imageDescp;
  String _remarksTFValue;

  List<dynamic> _availableDates = [];
  String _selectedBookDate;
  String _selectedBookTime;
  DateTime _selectedDate;
  TimeOfDay _selectedTime;

  List<ItemTypeModel> _itemTypes = [
    ItemTypeModel(name: 'Document', nameLocalizedKey: 'document'),
    // ItemTypeModel(
    //     name: 'Food and Beverage', nameLocalizedKey: 'food_n_beverage'),
    ItemTypeModel(name: 'Gift', nameLocalizedKey: 'gift'),
    ItemTypeModel(name: 'Groceries', nameLocalizedKey: 'groceries'),
    ItemTypeModel(name: 'Flower', nameLocalizedKey: 'flower'),
    ItemTypeModel(name: 'Cake', nameLocalizedKey: 'cake'),
    ItemTypeModel(name: 'Others', nameLocalizedKey: 'others'),
  ];
  ItemTypeModel _selectedItemType;
  String _itemTypeDescpTFValue;
  String _priorityFeeTFValue;

  @override
  void initState() {
    super.initState();

    loadAvailableDates();
  }

  void proceedToReview() async {
    if (_selectedItemType == null) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_select_delivery_item_type'),
          context);
      return;
    }

    if (_selectedItemType.name == 'Others' &&
        (_itemTypeDescpTFValue == null || _itemTypeDescpTFValue.isEmpty)) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_enter_delivery_item_desc_if_select_others'),
          context);
      return;
    }

    var confirm = await showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context)
                  .text('confirm_to_place_order_ques'),
              message: AppTranslations.of(context)
                      .text('are_you_sure_to_place_the_order_ques') +
                  ' at ' +
                  _selectedBookDate +
                  ' ' +
                  _selectedBookTime +
                  '?',
            ));

    if (confirm != 'confirm') return;

    BookingModel().setPickupDateAndTime(_selectedBookDate, _selectedBookTime);
    BookingModel()
        .setPhotoAndDescription(_encodedImage, _uploadedImageUrl, _imageDescp);
    BookingModel()
        .setDeliveryItemDetails(_selectedItemType, _itemTypeDescpTFValue);
    BookingModel().setPriorityFee(_priorityFeeTFValue ?? '');
    BookingModel().setRemarks(_remarksTFValue ?? '');

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": BookingModel().getBookingData(),
    };
//    print(params);
    print('create/update booking');
    printWrapped(params.toString());

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await BookingNetworking().createBooking(params);

      Navigator.pushNamed(context, DeliveryReviewPage.id).then((results) {
        if (results is PopWithResults) {
          PopWithResults popResult = results;
          if (popResult.toPage == DeliveryDetailsPage.id) {
            // TODO do stuff
          } else {
            // pop to previous page
            Navigator.of(context).pop(results);
          }
        }
      });
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e.toString(), context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  void resizeImageAndEncode(File imageToEncode) async {
    Img.Image image = Img.decodeImage(imageToEncode.readAsBytesSync());
    Img.Image resizedImage = Img.copyResize(image, height: 400);
    String encodedImage = base64Encode(Img.encodePng(resizedImage));

    uploadPhoto(encodedImage);
  }

  void uploadPhoto(String encodedImage) async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {"imageData": encodedImage},
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await BookingNetworking().uploadPhoto(params);

      if (data is String) {
        String imageUrl = data;
        _uploadedImageUrl = imageUrl;
        _encodedImage = encodedImage;
      }
    } catch (e) {
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void loadAvailableDates() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await BookingNetworking().getAvailableBookingDates(params);

      if (data is List<dynamic>) {
        setState(() {
          _availableDates = data;
          if (_availableDates.length > 0) {
            Map<String, dynamic> firstDateObj = _availableDates[0];
            String firstDate = firstDateObj.keys.first;

            List<dynamic> timeList = firstDateObj[firstDate];

            if (timeList.length == 0) {
              firstDateObj = _availableDates[1];
              firstDate = firstDateObj.keys.first;
            }

            print('first date: $firstDate');
            _selectedBookDate = firstDate;
            _selectedBookTime = firstDateObj[firstDate][0];
          }
        });
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.of(context).text('delivery_details'),
              style: kAppBarTextStyle),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            AppTranslations.of(context)
                                .text('select_pickup_date_n_time'),
                            textAlign: TextAlign.center,
                            style: kTitleTextStyle,
                          ),
                          SizedBox(height: 10.0),
                          dateAndTimeSelectionView(),
                          SizedBox(height: 30.0),
                          Text(
                            AppTranslations.of(context).text('upload_photo'),
                            textAlign: TextAlign.center,
                            style: kTitleTextStyle,
                          ),
                          SizedBox(height: 10.0),
                          uploadPhotoWidget(),
                          SizedBox(height: 10.0),
                          RemarksTextBox(
                            hintText: AppTranslations.of(context)
                                .text('photo_description'),
                            onChanged: (value) {
                              _imageDescp = value;
                            },
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            AppTranslations.of(context)
                                .text('delivery_item_details'),
                            textAlign: TextAlign.center,
                            style: kTitleTextStyle,
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            AppTranslations.of(context)
                                .text('select_your_delivery_item_type'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: poppinsRegular,
                                fontSize: 16,
                                color: Colors.red[400]),
                          ),
                          SizedBox(height: 10.0),
                          Wrap(
                            children: _deliveryItemTypesSelections(),
                          ),
                          SizedBox(height: 10.0),
                          RemarksTextBox(
                            hintText: AppTranslations.of(context).text(
                                'describe_deliver_item_here_mandatory_if_select_others'),
                            onChanged: (value) {
                              _itemTypeDescpTFValue = value;
                            },
                          ),
                          // SizedBox(height: 25.0),
                          // Text(
                          //   AppTranslations.of(context).text('priority_fee'),
                          //   textAlign: TextAlign.center,
                          //   style: kTitleTextStyle,
                          // ),
                          // SizedBox(height: 10.0),
                          // Row(
                          //   children: <Widget>[
                          //     Text(
                          //       "RM",
                          //       style: TextStyle(
                          //           fontFamily: poppinsRegular, fontSize: 16),
                          //     ),
                          //     SizedBox(width: 10.0),
                          //     Expanded(
                          //       child: InputTextField(
                          //         hintText: AppTranslations.of(context)
                          //             .text('priority_fee_optional'),
                          //         inputType: TextInputType.number,
                          //         onChange: (value) {
                          //           _priorityFeeTFValue = value;
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          SizedBox(height: 25.0),
                          Text(
                            AppTranslations.of(context).text('remarks'),
                            textAlign: TextAlign.center,
                            style: kTitleTextStyle,
                          ),
                          SizedBox(height: 10.0),
                          RemarksTextBox(
                            hintText: AppTranslations.of(context).text(
                                'remarks_or_instruction_to_rider_optional'),
                            onChanged: (value) {
                              _remarksTFValue = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    // Divider(color: Colors.black),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: ActionButton(
                        buttonText: AppTranslations.of(context).text('next'),
                        onPressed: () {
                          proceedToReview();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _deliveryItemTypesSelections() {
    List<Widget> itemTypeList = [];

    for (ItemTypeModel type in _itemTypes) {
      Widget button = GestureDetector(
        onTap: () {
          setState(() {
            _selectedItemType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          margin: EdgeInsets.only(right: 10.0, bottom: 10.0),
          decoration: BoxDecoration(
              color: (_selectedItemType == type) ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                  width: 1.0,
                  color:
                      (_selectedItemType == type) ? Colors.red : Colors.grey)),
          child: Text(
            AppTranslations.of(context).text(type.nameLocalizedKey),
            style: TextStyle(
                fontFamily: (_selectedItemType == type)
                    ? poppinsMedium
                    : poppinsRegular,
                fontSize: 14,
                color: (_selectedItemType == type)
                    ? Colors.white
                    : Colors.black54),
          ),
        ),
      );

      itemTypeList.add(button);
    }

    return itemTypeList;
  }

  Widget dateAndTimeSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 80,
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> dateData = _availableDates[index];
              String date = dateData.keys.first;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBookDate = date;
                  });
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: kColorRed, width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color:
                        (_selectedBookDate == date) ? kColorRed : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      '${DatetimeFormatter().getFormattedDateStr(format: 'dd MMM', datetime: '$date 00:00:00')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: (_selectedBookDate == date)
                              ? poppinsSemiBold
                              : poppinsRegular,
                          fontSize: 16,
                          color: (_selectedBookDate == date)
                              ? Colors.white
                              : kColorRed),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 10.0);
            },
            itemCount: _availableDates.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          height: 200,
          child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              List<dynamic> times = getTimesForSelectedDate();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBookTime = times[index];
                  });
                },
                child: Container(
                  height: 45.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: kColorRed, width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: (_selectedBookTime == times[index])
                        ? kColorRed
                        : Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      '${times[index]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: (_selectedBookTime == times[index])
                            ? poppinsSemiBold
                            : poppinsRegular,
                        fontSize: 16,
                        color: (_selectedBookTime == times[index])
                            ? Colors.white
                            : kColorRed,
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 10.0);
            },
            itemCount: getTimesForSelectedDate().length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }

  List<dynamic> getTimesForSelectedDate() {
    for (Map<String, dynamic> date in _availableDates) {
      String dateStr = date.keys.first;

      if (_selectedBookDate == dateStr) {
        return date[dateStr];
      }
    }

    return [];
  }

  // Not using
  Widget selectDateTimeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(Icons.date_range),
              SizedBox(width: 15.0),
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    if (Platform.isIOS) {
                      _showIOSDatePicker();
                    } else {
                      _showAndroidDatePicker();
                    }
                  },
                  color: kColorRed,
                  textColor: Colors.white,
                  child: Text(
                    (_selectedDate != null)
                        ? '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}'
                        : AppTranslations.of(context).text('select_date'),
                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 14),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(Icons.access_time),
              SizedBox(width: 15.0),
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    if (Platform.isIOS) {
                      _showIOSTimePicker();
                    } else {
                      _showAndroidTimePicker();
                    }
                  },
                  color: kColorRed,
                  textColor: Colors.white,
                  child: Text(
                    (_selectedTime != null)
                        ? '${DateFormat('hh:mm a').format(DateTime(0000, 01, 01, _selectedTime.hour, _selectedTime.minute))}'
                        : AppTranslations.of(context).text('select_time'),
                    style: TextStyle(fontFamily: poppinsMedium, fontSize: 14),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // Show iOS date picker
  void _showIOSDatePicker() {
    CupertinoDatetimePickerPopup().showCupertinoPicker(context,
        mode: CupertinoDatePickerMode.date,
        minDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDate: DateTime.now(), onChanged: (DateTime value) {
      if (value != null) {
        setState(() {
          _selectedDate = value;
        });
      }
    });
  }

  void _showIOSTimePicker() {
    CupertinoDatetimePickerPopup().showCupertinoPicker(context,
        mode: CupertinoDatePickerMode.time,
        initialDate: DateTime.now(), onChanged: (DateTime value) {
      if (value != null) {
        setState(() {
          _selectedTime = TimeOfDay(hour: value.hour, minute: value.minute);
        });
      }
    });
  }

  // Android Date picker
  void _showAndroidDatePicker() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: DateTime.now(),
    );

    if (date != null)
      setState(() {
        _selectedDate = date;
      });
  }

  // Android Time picker
  void _showAndroidTimePicker() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (t != null)
      setState(() {
        _selectedTime = t;
      });
  }

  Widget uploadPhotoWidget() {
    if (_encodedImage != null) {
      Uint8List bytes = base64Decode(_encodedImage);
      return GestureDetector(
        onTap: () {
          showPickImageBottomSheet();
        },
        child: Image.memory(
          bytes,
          height: 200,
          fit: BoxFit.fitHeight,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          showPickImageBottomSheet();
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              style: BorderStyle.solid,
              color: Colors.black,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/add_image.png'),
              SizedBox(height: 8.0),
              Text(
                AppTranslations.of(context)
                    .text('take_picture_or_select_from_gallery'),
                style: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
  }

  void showPickImageBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) => UploadImagePopup()).then((value) {
      String method = value;
      if (method == 'camera') {
        getImageFromCamera();
      } else if (method == 'gallery') {
        getImageFromGallery();
      }
    });
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 500, imageQuality: 80);

    setState(() {
      File imageURI = File(image.path);
      resizeImageAndEncode(imageURI);
    });
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery, maxHeight: 500, imageQuality: 80);

    setState(() {
      File imageURI = File(image.path);
      resizeImageAndEncode(imageURI);
    });
  }
}
