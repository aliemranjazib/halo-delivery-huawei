// To parse this JSON data, do
//
//     final topUpTransactionResponse = topUpTransactionResponseFromJson(jsonString);

import 'dart:convert';

TopUpTransactionResponse topUpTransactionResponseFromJson(String str) => TopUpTransactionResponse.fromJson(json.decode(str));

String topUpTransactionResponseToJson(TopUpTransactionResponse data) => json.encode(data.toJson());

class TopUpTransactionResponse {
  TopUpTransactionResponse({
    this.msg,
    this.response,
  });

  String msg;
  Response response;

  factory TopUpTransactionResponse.fromJson(Map<String, dynamic> json) => TopUpTransactionResponse(
    msg: json["msg"] == null ? null : json["msg"],
    response: json["response"] == null ? null : Response.fromJson(json["response"]),
  );

  Map<String, dynamic> toJson() => {
    "msg": msg == null ? null : msg,
    "response": response == null ? null : response.toJson(),
  };
}

class Response {
  Response({
    this.topupTransactions,
    this.walletBalance,
  });

  List<TopupTransaction> topupTransactions;
  String walletBalance;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    topupTransactions: json["topupTransactions"] == null ? null : List<TopupTransaction>.from(json["topupTransactions"].map((x) => TopupTransaction.fromJson(x))),
    walletBalance: json["walletBalance"] == null ? null : json["walletBalance"],
  );

  Map<String, dynamic> toJson() => {
    "topupTransactions": topupTransactions == null ? null : List<dynamic>.from(topupTransactions.map((x) => x.toJson())),
    "walletBalance": walletBalance == null ? null : walletBalance,
  };
}

class TopupTransaction {
  TopupTransaction({
    this.topupId,
    this.walletId,
    this.topupNumber,
    this.topupAmount,
    this.topupDatetime,
    this.topupUpdateDatetime,
    this.topupStatus,
    this.topupMethod,
    this.topupRemarks,
    this.topupCharges,
    this.topupTotalPaid,
  });

  String topupId;
  String walletId;
  String topupNumber;
  String topupAmount;
  DateTime topupDatetime;
  DateTime topupUpdateDatetime;
  String topupStatus;
  String topupMethod;
  String topupRemarks;
  String topupCharges;
  String topupTotalPaid;

  factory TopupTransaction.fromJson(Map<String, dynamic> json) => TopupTransaction(
    topupId: json["topup_id"] == null ? null : json["topup_id"],
    walletId: json["wallet_id"] == null ? null : json["wallet_id"],
    topupNumber: json["topup_number"] == null ? null : json["topup_number"],
    topupAmount: json["topup_amount"] == null ? null : json["topup_amount"],
    topupDatetime: json["topup_datetime"] == null ? null : DateTime.parse(json["topup_datetime"]),
    topupUpdateDatetime: json["topup_update_datetime"] == null ? null : DateTime.parse(json["topup_update_datetime"]),
    topupStatus: json["topup_status"] == null ? null : json["topup_status"],
    topupMethod: json["topup_method"] == null ? null : json["topup_method"],
    topupRemarks: json["topup_remarks"] == null ? null : json["topup_remarks"],
    topupCharges: json["topup_charges"] == null ? null : json["topup_charges"],
    topupTotalPaid: json["topup_total_paid"] == null ? null : json["topup_total_paid"],
  );

  Map<String, dynamic> toJson() => {
    "topup_id": topupId == null ? null : topupId,
    "wallet_id": walletId == null ? null : walletId,
    "topup_number": topupNumber == null ? null : topupNumber,
    "topup_amount": topupAmount == null ? null : topupAmount,
    "topup_datetime": topupDatetime == null ? null : topupDatetime.toIso8601String(),
    "topup_update_datetime": topupUpdateDatetime == null ? null : topupUpdateDatetime.toIso8601String(),
    "topup_status": topupStatus == null ? null : topupStatus,
    "topup_method": topupMethod == null ? null : topupMethod,
    "topup_remarks": topupRemarks == null ? null : topupRemarks,
    "topup_charges": topupCharges == null ? null : topupCharges,
    "topup_total_paid": topupTotalPaid == null ? null : topupTotalPaid,
  };
}
