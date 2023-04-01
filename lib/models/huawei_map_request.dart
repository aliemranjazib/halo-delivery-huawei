// To parse this JSON data, do
//
//     final huaweiMapRouteRequest = huaweiMapRouteRequestFromJson(jsonString);

import 'dart:convert';

HuaweiMapRouteRequest huaweiMapRouteRequestFromJson(String str) => HuaweiMapRouteRequest.fromJson(json.decode(str));

String huaweiMapRouteRequestToJson(HuaweiMapRouteRequest data) => json.encode(data.toJson());

class HuaweiMapRouteRequest {
  HuaweiMapRouteRequest({
    this.origin,
    this.destination,
    this.waypoints,
  });

  Destination origin;
  Destination destination;
  List<Destination> waypoints;

  factory HuaweiMapRouteRequest.fromJson(Map<String, dynamic> json) => HuaweiMapRouteRequest(
    origin: json["origin"] == null ? null : Destination.fromJson(json["origin"]),
    destination: json["destination"] == null ? null : Destination.fromJson(json["destination"]),
    waypoints: json["waypoints"] == null ? null : List<Destination>.from(json["waypoints"].map((x) => Destination.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "origin": origin == null ? null : origin.toJson(),
    "destination": destination == null ? null : destination.toJson(),
    "waypoints": waypoints == null ? null : List<dynamic>.from(waypoints.map((x) => x.toJson())),
  };
}

class Destination {
  Destination({
    this.lat,
    this.lng,
  });

  String lat;
  String lng;

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    lat: json["lat"] == null ? null : json["lat"],
    lng: json["lng"] == null ? null : json["lng"],
  );

  Map<String, dynamic> toJson() => {
    "lat": lat == null ? null : lat,
    "lng": lng == null ? null : lng,
  };
}
