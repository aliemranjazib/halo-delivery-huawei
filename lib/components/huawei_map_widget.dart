import 'package:flutter/cupertino.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:huawei_map/components/marker.dart';
import 'package:huawei_map/components/polyline.dart';
import 'package:huawei_map/components/polylineId.dart';
import 'package:huawei_map/map.dart';

class HuaweiMapWidget extends StatelessWidget {
  HuaweiMapWidget(
      {@required this.onMapCreated,
      @required this.location,
      this.markers,
      this.polylines});

  final Function onMapCreated;
  final LatLng location;
  final Map<String, Marker> markers;
  final Map<PolylineId, Polyline> polylines;

  @override
  Widget build(BuildContext context) {
    return HuaweiMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: 15,
      ),
      myLocationEnabled: true,
      markers: markers.values.toSet(),
      polylines: polylines.values.toSet(),
    );
  }
}
