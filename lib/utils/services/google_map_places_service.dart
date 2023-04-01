import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/google_places_component_model.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert';
import 'dart:math';

import 'package:huawei_map/map.dart' as huaweiMap;

import '../utils.dart';

final places = new GoogleMapsPlaces(apiKey: APIUrls().getGoogleAPIKey());

class GoogleMapPlacesService {
  Future<Map<String, dynamic>> getRoute(
      List<AddressModel> addresses, bool generatePoly) async {
    if (addresses.length >= 2) {
      String directionQuery =
          'origin=${addresses[0].lat},${addresses[0].lng}&destination=${addresses[1].lat},${addresses[1].lng}';

      if (addresses.length > 2) {
        String waypointQuery = '';

        for (int i = 2; i <= addresses.length - 1; i++) {
          if (i == addresses.length - 1) {
            waypointQuery =
                waypointQuery + '${addresses[i].lat},${addresses[i].lng}';
          } else {
            waypointQuery =
                waypointQuery + '${addresses[i].lat},${addresses[i].lng}|';
          }
        }

        directionQuery = directionQuery + '&waypoints=$waypointQuery';
      }

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?$directionQuery&key=${APIUrls().getGoogleAPIKey()}';
      HTTP.Response response = await HTTP.get(Uri.parse(url));
      Map values = jsonDecode(response.body);
      String polylineStr = values["routes"][0]["overview_polyline"]["points"];

      var totalDistance = 0;
      var totalDuration = 0;
      var legs = values["routes"][0]["legs"];
      for (var i = 0; i < legs.length; ++i) {
        totalDistance += legs[i]["distance"]["value"];
        totalDuration += legs[i]["duration"]["value"];
      }

      if (generatePoly) {
        if (polylineStr != null && polylineStr.isNotEmpty) {
          List decodedPoly = _decodePoly(polylineStr);

          if (decodedPoly.length > 0) {
            List<huaweiMap.LatLng> latLngList = _convertToLatLng(decodedPoly);

            Map<String, dynamic> data = {
              'latLngList': latLngList,
              'distance': totalDistance,
            };

            return data;
          } else {
            throw "";
          }
        } else {
          throw values["status"];
        }
      } else {
        Map<String, dynamic> data = {
          'distance': totalDistance,
          'duration': totalDuration,
        };

        return data;
      }
    }
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;

    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];
    print(lList.toString());

    return lList;
  }

  List<huaweiMap.LatLng> _convertToLatLng(List points) {
    List<huaweiMap.LatLng> result = <huaweiMap.LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(huaweiMap.LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  huaweiMap.LatLngBounds getBounds(List<huaweiMap.Marker> markers) {
    var lngs = markers.map<double>((m) => m.position.lng).toList();
    var lats = markers.map<double>((m) => m.position.lat).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    huaweiMap.LatLngBounds bounds = huaweiMap.LatLngBounds(
      northeast: huaweiMap.LatLng(rightMost, topMost),
      southwest: huaweiMap.LatLng(leftMost, bottomMost),
    );

    return bounds;
  }

  GooglePlacesComponentModel getDelegatedComponent(PlaceDetails detail) {
    GooglePlacesComponentModel componentModel = GooglePlacesComponentModel();
    componentModel.lat = detail.geometry.location.lat;
    componentModel.lng = detail.geometry.location.lng;

    print(componentModel.lat);
    print(componentModel.lng);

    for (AddressComponent component in detail.addressComponents) {
      String componentType = component.types.first;
      if (componentType == 'street_number') {
        componentModel.street = component.longName;
      }

      if (componentType == 'route') {
        componentModel.route = component.longName;
      }

      if (componentType == 'locality') {
        componentModel.city = component.longName;
      }

      if (componentType == 'administrative_area_level_1') {
        componentModel.state = component.longName;
      }

      if (componentType == 'postal_code') {
        componentModel.zip = component.longName;
      }

      if (componentType == 'country') {
        componentModel.country = component.longName;
      }

      if (componentType == 'sublocality') {
        if (componentModel.route == null || componentModel.route == '') {
          componentModel.route = component.longName;
        }
      }

      if (componentType == 'sublocality_level_1') {
        if (componentModel.route == null || componentModel.route == '') {
          componentModel.route = component.longName;
        }
      }
    }

    return componentModel;
  }

  Future<Map<String, dynamic>> getPlaceComponentByLocation(
      huaweiMap.LatLng location) async {
    print('start2');
    String url =
        'https://revgeocode.search.hereapi.com/v1/revgeocode?at=${location.lat},${location.lng}&apiKey=JkRyd6Bix2G0dpznJGY1oy7UUe05ifYs6PWZTWR3NqQ';
    print('start3');
    HTTP.Response response = await HTTP.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    Map<String, dynamic> result = values['items'][0]['address'];
    print(result);
    GooglePlacesComponentModel componentModel = GooglePlacesComponentModel();
    componentModel.lat = location.lat;
    componentModel.lng = location.lng;

    componentModel.street = result['street'];
    componentModel.route = result['district'];
    componentModel.city = result['city'];
    componentModel.state = result['state'];
    componentModel.zip = result['postalCode'];
    componentModel.country = result['countryName'];
    componentModel.route = result['district'];
    return {"components": componentModel, "fullAddress": result['label']};
  }

  static Future<List<Prediction>> searchPlaceByText(place) async {
    PlacesAutocompleteResponse response = await places
        .autocomplete(place, components: [Component(Component.country, "my")]);
    return response.predictions;
  }

  static Future<PlaceDetails> searchPlaceById(id) async {
    PlacesDetailsResponse response =
        await places.getDetailsByPlaceId(id, fields: Utils.fields);
    print(response.result.geometry.toJson());
    print(response.result.types.toString());
    print(response.result.formattedAddress.toString());
    response.result.addressComponents.forEach((element) {
      print(element.toJson());
    });

    return response.result;
  }

  static getAutoComplete(text) async {
    var url =
        'https://revgeocode.search.hereapi.com/v1/autocomplete?apiKey=JkRyd6Bix2G0dpznJGY1oy7UUe05ifYs6PWZTWR3NqQ&q=$text&in=countryCode:MYS';
    HTTP.Response response = await HTTP.get(Uri.parse(url));
    return jsonDecode(response.body)['items'];
  }

  static getPlaceById(id) async {
    var url =
        'https://lookup.search.hereapi.com/v1/lookup?apiKey=JkRyd6Bix2G0dpznJGY1oy7UUe05ifYs6PWZTWR3NqQ&id=' +
            id;
    HTTP.Response response = await HTTP.get(Uri.parse(url));
    // print(response.body);
    return jsonDecode(response.body);
  }
}
// Future<Map<String, dynamic>> getPlaceComponentByLocation(
//     LatLng location) async {
//   String url =
//       'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=${APIUrls().getGoogleAPIKey()}';

//   HTTP.Response response = await HTTP.get(url);
//   Map values = jsonDecode(response.body);
//   Map<String, dynamic> result = values['results'][0];
//   print(result);

//   if (result == null || result['formatted_address'] == null) {
//     throw values["status"];
//   } else {
//     GooglePlacesComponentModel componentModel = GooglePlacesComponentModel();
//     componentModel.lat = location.latitude;
//     componentModel.lng = location.longitude;

//     List<dynamic> returnComponents = result['address_components'];

//     for (Map<String, dynamic> component in returnComponents) {
//       List<dynamic> componentTypes = component['types'];
//       String componentType = componentTypes.first;

//       if (componentTypes
//               .where((element) => element == 'street_number')
//               .toList()
//               .length >
//           0) {
//         componentModel.street = component['long_name'];
//       }

//       if (componentType == 'route') {
//         componentModel.route = component['long_name'];
//       }

//       if (componentType == 'locality') {
//         componentModel.city = component['long_name'];
//       }

//       if (componentType == 'administrative_area_level_1') {
//         componentModel.state = component['long_name'];
//       }

//       if (componentType == 'postal_code') {
//         componentModel.zip = component['long_name'];
//       }

//       if (componentType == 'country') {
//         componentModel.country = component['long_name'];
//       }

//       if (componentTypes
//               .where((element) => element == 'sublocality')
//               .toList()
//               .length >
//           0) {
//         if (componentModel.route == null || componentModel.route == '') {
//           componentModel.route = component['long_name'];
//         }
//       }

//       if (componentTypes
//               .where((element) => element == 'sublocality_level_1')
//               .toList()
//               .length >
//           0) {
//         if (componentModel.route == null || componentModel.route == '') {
//           componentModel.route = component['long_name'];
//         }
//       }
//     }

//     return {
//       "components": componentModel,
//       "fullAddress": result['formatted_address']
//     };
//   }
// }
