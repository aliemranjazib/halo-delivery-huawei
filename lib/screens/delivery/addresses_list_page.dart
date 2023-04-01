import 'package:flutter/material.dart';
import 'package:haloapp/components/address_view.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import '../../components/action_button.dart';
import 'package:haloapp/screens/main/add_address_page.dart';

class AddressesListPage extends StatefulWidget {
  static const String id = 'addressesListPage';

  @override
  _AddressesListPageState createState() => _AddressesListPageState();
}

class _AddressesListPageState extends State<AddressesListPage> {
  bool _isSorting = false;
  List<AddressModel> sortedAddresses = [];

  void addAddress(int index) async {
    dynamic refresh = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddAddressPage(addressIndex: index)));

    if (refresh == 'refresh') {
      setState(() {});
    }
  }

  void removeAddress(int index) {
    String address = BookingModel().getAddressAtIndex(index).fullAddress;

    showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
              title: AppTranslations.of(context).text('remove_address'),
              message:
                  '${AppTranslations.of(context).text('are_you_sure_to_remove_this_address')} \n $address',
            )).then((value) {
      if (value != null && value == 'confirm') {
        setState(() {
          BookingModel().removeAddressAtIndex(index);
        });
      }
    });
  }

  _startSortingAddresses() {
    // Copy booking addresses for sorting
    for (int i = 1; i < BookingModel().getAllAddresses().length; i++) {
      AddressModel address = BookingModel().getAllAddresses()[i];

      sortedAddresses.add(AddressModel(
          type: address.type,
          fullAddress: address.fullAddress,
          lat: address.lat,
          lng: address.lng,
          street: address.street,
          city: address.city,
          state: address.state,
          zip: address.zip,
          unitNo: address.unitNo,
          buildingName: address.buildingName,
          receiverName: address.receiverName,
          receiverPhone: address.receiverPhone,
          remarks: address.remarks,
          addressId: address.addressId,
          paymentCollect: address.paymentCollect));
    }

    setState(() {
      _isSorting = true;
    });
  }

  _saveSortedAddresses() {
    // Remove all drop off addresses
    BookingModel().removeAllDropoffAddresses();

    // Save new sorted addresses in booking addresses
    for (AddressModel address in sortedAddresses) {
      BookingModel().addAddress(AddressModel(
          type: address.type,
          fullAddress: address.fullAddress,
          lat: address.lat,
          lng: address.lng,
          street: address.street,
          city: address.city,
          state: address.state,
          zip: address.zip,
          unitNo: address.unitNo,
          buildingName: address.buildingName,
          receiverName: address.receiverName,
          receiverPhone: address.receiverPhone,
          remarks: address.remarks,
          addressId: address.addressId,
          paymentCollect: address.paymentCollect));
    }

    setState(() {
      sortedAddresses = [];
      _isSorting = false;
    });
  }

  void _updateReorderAddress(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final AddressModel item = sortedAddresses.removeAt(oldIndex);
    sortedAddresses.insert(newIndex, item);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          // title: Text('tttyty'),
          automaticallyImplyLeading: !_isSorting,
          actions: <Widget>[
            _isSorting
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: GestureDetector(
                        onTap: () {
                          // Save the sorted addresses result
                          _saveSortedAddresses();
                        },
                        child: Text(
                          AppTranslations.of(context).text('save'),
                          style: TextStyle(
                              fontFamily: poppinsMedium, fontSize: 16),
                        )),
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: GestureDetector(
                        onTap: () {
                          _startSortingAddresses();
                        },
                        child: Text(
                          AppTranslations.of(context).text('sort'),
                          style: TextStyle(
                              fontFamily: poppinsMedium, fontSize: 16),
                        )),
                  )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _isSorting
                ? Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          color: Colors.red[100],
                          child: Text(
                            AppTranslations.of(context)
                                .text('hold_n_drag_address_to_sort'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: poppinsItalic,
                                fontSize: 14,
                                color: Colors.red),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(15.0),
                          color: Colors.grey[200],
                          child: Text(
                            BookingModel().getAllAddresses()[0].fullAddress,
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: poppinsMedium,
                                fontSize: 16),
                            maxLines: 3,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView(
                            children:
                                List.generate(sortedAddresses.length, (index) {
                              return Container(
                                key: ValueKey('$index'),
                                padding: EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              sortedAddresses[index]
                                                  .fullAddress,
                                              style: kAddressTextStyle,
                                              maxLines: 3,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.sort)
                                      ],
                                    ),
                                    Divider(height: 2)
                                  ],
                                ),
                              );
                            }),
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                _updateReorderAddress(oldIndex, newIndex);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        // Set max 5 dropoff addresses
                        itemCount:
                            (BookingModel().getAllAddresses().length == 6)
                                ? BookingModel().getAllAddresses().length
                                : BookingModel().getAllAddresses().length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                        child: AddressView(addressIndex: index),
                                        onTap: () {
                                          addAddress(index);
                                        },
                                      ),
                                    ),
                                    (index != 0 &&
                                            index != 1 &&
                                            index !=
                                                BookingModel()
                                                    .getAllAddresses()
                                                    .length)
                                        ? SizedBox(
                                            width: 35.0,
                                            child: ElevatedButton(
                                              child: Icon(Icons.delete_forever),
                                              // padding: EdgeInsets.zero,
                                              onPressed: () {
                                                removeAddress(index);
                                              },
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                                Divider(height: 2)
                              ]);
                        }),
                  ),
          ],
        ),
      ),
    );
  }
}
