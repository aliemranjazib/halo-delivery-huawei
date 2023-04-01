import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/cupertino_datetime_picker_popup.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'dart:math' as math;

import 'package:haloapp/components_new/date_time_selection_view.dart';
import 'package:haloapp/components_new/selection_check_box.dart';
import 'package:haloapp/components_new/vehicle_card.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/item_type_model.dart';
import 'package:haloapp/models/vehicle_model.dart';

import 'package:haloapp/networkings/booking_networking.dart';
import 'package:haloapp/screens/delivery/delivery_review_page.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/screens/general/custom_buttons_dialog.dart';
import 'package:haloapp/screens/general/upload_image_popup.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/constants/vehicles.dart';
import 'package:haloapp/utils/services/pop_with_result_service.dart';
import 'package:image_picker/image_picker.dart';
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

  List<VehicleModel> _vehicles = Vehicles().getVehicles();

  ItemTypeModel _selectedItemType;
  String _itemTypeDescpTFValue;
  String _priorityFeeTFValue;

  VehicleModel _selectedVehicle = Vehicles().getVehicles()[0];
  String _distance = BookingModel().getDeliveryDistance();

  @override
  void initState() {
    super.initState();

    loadAvailableDates();

    getDistancePrice();
    _selectedItemType = _itemTypes[0];
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
        builder: (context) => CustomButtonAlertDialog(
              title: AppTranslations.of(context)
                  .text('confirm_to_place_order_ques'),
              message: AppTranslations.of(context)
                      .text('are_you_sure_to_place_the_order_ques') +
                  ' at ' +
                  _selectedBookDate +
                  ' ' +
                  _selectedBookTime +
                  '?',
              buttonText: AppTranslations.of(context).text("cancel"),
              buttonOnClick: () {
                Navigator.pop(context);
              },
              buttonText2: AppTranslations.of(context).text("confirm"),
              buttonOnClick2: () {
                Navigator.pop(context, 'confirm');
              },
            ));

    if (confirm != 'confirm') return;

    BookingModel().setPickupDateAndTime(_selectedBookDate, _selectedBookTime);
    BookingModel()
        .setPhotoAndDescription(_encodedImage, _uploadedImageUrl, _imageDescp);
    BookingModel()
        .setDeliveryItemDetails(_selectedItemType, _itemTypeDescpTFValue);
    BookingModel().setPriorityFee(_priorityFeeTFValue ?? '');
    BookingModel().setRemarks(_remarksTFValue ?? '');
    BookingModel().setVehicle(_selectedVehicle);

    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": BookingModel().getBookingData(),
    };
//    print(params);
    print('create/update booking');
    print(BookingModel().getVehicle().id);

    print(BookingModel().getDistancePrice());
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

  showDocTypeBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.of(context).text('type_of_item'),
                        style: kTitleTextStyle,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      List<ItemTypeModel> items = _itemTypes;
                      return SelectionCheckBox(
                        onPressed: () {
                          setState(() {
                            _selectedItemType = items[index];
                          });
                          Navigator.pop(context);
                        },
                        isSelected:
                            (_selectedItemType.name == items[index].name),
                        label: items[index].name,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: _itemTypes.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    setState(() {});
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

  void getDistancePrice() async {
    if (BookingModel().getAllAddresses() == null ||
        BookingModel().getAllAddresses().length < 2) {
      return;
    }

    for (var i = 0; i < _vehicles.length; i++) {
      Map<String, dynamic> params = {
        "apiKey": APIUrls().getApiKey(),
        "data": {
          "distance": _distance,
          "transportType": _vehicles[i].id,
          "addresses": BookingModel().getAddressesListData(),
        }
      };
      print(params);

      setState(() {
        _showSpinner = true;
      });

      try {
        var data = await BookingNetworking().getDistancePrice(params);

        setState(() {
          _vehicles[i].price = data;
          if (_vehicles.isNotEmpty) {
            _selectedVehicle = _vehicles.first;
          }
        });
      } catch (e) {
        showSimpleFlushBar(e, context);
        _vehicles.removeAt(i);
      } finally {
        setState(() {
          _showSpinner = false;
        });
      }
    }
  }

  renderDocumentType() {
    return GestureDetector(
      onTap: () {
        showDocTypeBottomSheet();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(_selectedItemType.name),
            ),
            Transform.rotate(
              angle: -90 * math.pi / 180,
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
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
          centerTitle: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            AppTranslations.of(context).text('delivery_details'),
            style: kAppBarTextStyle,
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
              top: 6.0,
              left: 20.0,
              right: 20.0,
              bottom: MediaQuery.of(context).padding.bottom + 6.0),
          child: Wrap(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${AppTranslations.of(context).text("total")} - RM${_selectedVehicle.price} (${_selectedVehicle.name})',
                      style:
                          TextStyle(fontFamily: poppinsSemiBold, fontSize: 16),
                    )),
              ),
              ActionButton(
                buttonText:
                    AppTranslations.of(context).text("review_delivery_details"),
                onPressed: () {
                  proceedToReview();
                },
              )
            ],
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          color: Colors.white,
                          child: DateTimeSelectionView(
                            dateTitle:
                                AppTranslations.of(context).text('pickup_date'),
                            timeTitle:
                                AppTranslations.of(context).text('pickup_time'),
                            dateSelections: _availableDates,
                            timeSelections: getTimesForSelectedDate(),
                            onDateSelected: (date) {
                              setState(() {
                                _selectedBookDate = date;
                              });
                            },
                            onTimeSelected: (time) {
                              setState(() {
                                _selectedBookTime = time;
                              });
                            },
                            selectedDate: _selectedBookDate,
                            selectedTime: _selectedBookTime,
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${AppTranslations.of(context).text("vehicle_type")}',
                                    style: kAddressTextStyle,
                                  ),
                                  SizedBox(
                                    width: 3.0,
                                  ),
                                  Text(
                                    '${BookingModel().getDeliveryDistance()}KM',
                                    style: kTitleLargeBoldTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              ..._vehicles.map(
                                (e) => VehicleCard(
                                  vehcileImage: e.image,
                                  vehicleTitle: '${e.name} - RM${e.price}',
                                  vehicleDesc: e.description,
                                  vehicleMeasure: e.description2,
                                  isSelected: _selectedVehicle.id == e.id,
                                  onSelected: () {
                                    setState(() {
                                      _selectedVehicle = e;
                                      BookingModel().setDistanceAndPrice(
                                          _distance, e.price);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppTranslations.of(context)
                                    .text('delivery_item_details'),
                                style: kAddressTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                AppTranslations.of(context)
                                    .text('upload_placeholder'),
                                style: TextStyle(
                                  fontFamily: poppinsRegular,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              uploadPhotoWidget(),
                              SizedBox(height: 10.0),
                              renderDocumentType(),
                              SizedBox(height: 10.0),
                              InputTextField(
                                hintText: AppTranslations.of(context)
                                    .text('item_description'),
                                onChange: (value) {
                                  _itemTypeDescpTFValue = value;
                                },
                              ),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppTranslations.of(context)
                                    .text('special_instructions'),
                                style: kAddressTextStyle,
                              ),
                              SizedBox(height: 10.0),
                              InputTextField(
                                hintText: AppTranslations.of(context).text(
                                    'remarks_or_instruction_to_rider_optional'),
                                onChange: (value) {
                                  _remarksTFValue = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
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

  List<dynamic> getTimesForSelectedDate() {
    for (Map<String, dynamic> date in _availableDates) {
      String dateStr = date.keys.first;

      if (_selectedBookDate == dateStr) {
        return date[dateStr];
      }
    }

    return [];
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
          showRemoveImageDialog();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/ic_upload_doc.png',
                height: 150,
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      );
    }
  }

  void showRemoveImageDialog() {
    showDialog(
        context: context,
        builder: (context) => CustomButtonAlertDialog(
              title: AppTranslations.of(context).text("remove"),
              message: AppTranslations.of(context).text("remove_attachment"),
              buttonText: AppTranslations.of(context).text("cancel"),
              buttonOnClick: () {
                Navigator.pop(context);
              },
              buttonText2: AppTranslations.of(context).text("remove"),
              buttonOnClick2: () {
                Navigator.pop(context);
                setState(() {
                  _uploadedImageUrl = null;
                  _encodedImage = null;
                });
              },
            ));
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
