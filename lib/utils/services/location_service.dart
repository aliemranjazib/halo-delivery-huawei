import 'package:huawei_location/huawei_location.dart';
// import 'package:huawei_location/location/fused_location_provider_client.dart';
// import 'package:huawei_location/location/location.dart';
// import 'package:huawei_location/location/location_request.dart';
import 'package:location_permissions/location_permissions.dart';

class LocationService {
  static final FusedLocationProviderClient _locationService =
      FusedLocationProviderClient();
  static final LocationRequest _locationRequest = LocationRequest()
    ..interval = 500;

  LocationService._privateConstructor();
  static final LocationService _instance =
      LocationService._privateConstructor();
  Location _lastGetLocation;

  factory LocationService() {
    return _instance;
  }

  Future<Location> getCurrentLocation() async {
    print('@@@');
    try {
      final Location location = await _locationService.getLastLocation();

      _lastGetLocation = location;

      if (_lastGetLocation == null) {
        _lastGetLocation = await getLastKnownLocation();
      }

      return _lastGetLocation;
    } catch (_) {}
    return Location();
  }

  Location getLastLocation() {
    return _lastGetLocation;
  }

  static Future<Location> getLastKnownLocation() async {
    try {
      final Location location = await _locationService.getLastLocation();
      print(location);
      if (location != null) return location;

//      var position = await Geolocator.getLastKnownPosition();
//      if (position != null) return position;
//
//      position = await Geolocator.getCurrentPosition(
//          desiredAccuracy: LocationAccuracy.lowest,
//          forceAndroidLocationManager: true);
//      return position;
    } catch (_) {
      return Location();
    }

    return Location();
  }

  Future<bool> checkPermission() async {
    ServiceStatus serviceStatus =
        await LocationPermissions().checkServiceStatus();

    if (serviceStatus != ServiceStatus.enabled) {
      return false;
    } else {
      PermissionStatus permission =
          await LocationPermissions().checkPermissionStatus();

      if (permission != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }
}
