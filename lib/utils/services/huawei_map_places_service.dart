import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/google_places_component_model.dart';
import 'package:haloapp/models/huawei_map_request.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:http/http.dart' as HTTP;
import 'package:huawei_map/components/latLng.dart';
// import 'package:huawei_map/components/components.dart';
import 'dart:convert';
import 'dart:math';

import 'package:huawei_map/components/latLngBounds.dart';
import 'package:huawei_map/components/marker.dart';

// import 'package:huawei_map/components/marker.dart';
// import 'package:huawei_site/huawei_site.dart';
// import 'package:huawei_site/model/detail_search_request.dart';
// import 'package:huawei_site/model/detail_search_response.dart';
// import 'package:huawei_site/search_service.dart';

final huaweiKey = APIUrls().getHuaweiAPIKey();

class HuaweiMapPlacesService {
  LatLngBounds getBounds(List<Marker> markers) {
    var lngs = markers.map<double>((m) => m.position.lng).toList();
    var lats = markers.map<double>((m) => m.position.lat).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );

    return bounds;
  }

//  static Future<List<Prediction>> searchPlaceByText(place) async {
//    SearchService _searchService = await SearchService.create(huaweiKey);
//
//    PlacesAutocompleteResponse response = await places
//        .autocomplete(place, components: [Component(Component.country, "my")]);
//    return response.predictions;
//  }

  // static Future<Site> searchPlaceById(id) async {
  //   SearchService _searchService = await SearchService.create(huaweiKey);
  //   final DetailSearchRequest _request = DetailSearchRequest(siteId: id,language: "en");
  //   try {
  //     DetailSearchResponse response = await _searchService.detailSearch(_request);
  //     return response.site;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   return null;
  // }

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
