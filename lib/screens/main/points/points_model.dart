// To parse this JSON data, do
//
//     final pointsModel = pointsModelFromJson(jsonString);

import 'dart:convert';

PointsModel pointsModelFromJson(String str) =>
    PointsModel.fromJson(json.decode(str));

String pointsModelToJson(PointsModel data) => json.encode(data.toJson());

class PointsModel {
  PointsModel({
    this.msg,
    this.response,
  });

  String msg;
  Response response;

  factory PointsModel.fromJson(Map<String, dynamic> json) => PointsModel(
        msg: json["msg"],
        response: Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "response": response.toJson(),
      };
}

class Response {
  Response({
    this.pointTransactions,
    this.pointBalance,
    this.expireDetails,
  });

  List<PointTransaction> pointTransactions;
  String pointBalance;
  ExpireDetails expireDetails;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        pointTransactions: List<PointTransaction>.from(
            json["pointTransactions"].map((x) => PointTransaction.fromJson(x))),
        pointBalance: json["pointBalance"],
        expireDetails: ExpireDetails.fromJson(json["expireDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "pointTransactions":
            List<dynamic>.from(pointTransactions.map((x) => x.toJson())),
        "pointBalance": pointBalance,
        "expireDetails": expireDetails.toJson(),
      };
}

class ExpireDetails {
  ExpireDetails({
    this.pointAmount,
    this.expireDate,
  });

  String pointAmount;
  dynamic expireDate;

  factory ExpireDetails.fromJson(Map<String, dynamic> json) => ExpireDetails(
        pointAmount: json["pointAmount"],
        expireDate: json["expireDate"],
      );

  Map<String, dynamic> toJson() => {
        "pointAmount": pointAmount,
        "expireDate": expireDate,
      };
}

class PointTransaction {
  PointTransaction({
    this.transactionAmount,
    this.transactionType,
    this.transactionCreatedDatetime,
    this.transactionRemark,
  });

  String transactionAmount;
  String transactionType;
  DateTime transactionCreatedDatetime;
  String transactionRemark;

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      PointTransaction(
        transactionAmount: json["transaction_amount"],
        transactionType: json["transaction_type"],
        transactionCreatedDatetime:
            DateTime.parse(json["transaction_created_datetime"]),
        transactionRemark: json["transaction_remark"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_amount": transactionAmount,
        "transaction_type": transactionType,
        "transaction_created_datetime":
            transactionCreatedDatetime.toIso8601String(),
        "transaction_remark": transactionRemark,
      };
}
