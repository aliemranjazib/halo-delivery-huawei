// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class GoogleMapWidget extends StatelessWidget {
//   GoogleMapWidget(
//       {@required this.onMapCreated,
//       @required this.location,
//       this.markers,
//       this.polylines});

//   final Function onMapCreated;
//   final LatLng location;
//   final Map<String, Marker> markers;
//   final Map<PolylineId, Polyline> polylines;

//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       onMapCreated: onMapCreated,
//       initialCameraPosition: CameraPosition(
//         target: location,
//         zoom: 15,
//       ),
//       myLocationEnabled: true,
//       markers: markers.values.toSet(),
//       polylines: polylines.values.toSet(),
//     );
//   }
// }
