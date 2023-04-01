// To parse this JSON data, do
//
//     final walletTransactionsResponse = walletTransactionsResponseFromJson(jsonString);

import 'dart:convert';

WalletTransactionsResponse walletTransactionsResponseFromJson(String str) => WalletTransactionsResponse.fromJson(json.decode(str));

String walletTransactionsResponseToJson(WalletTransactionsResponse data) => json.encode(data.toJson());

class WalletTransactionsResponse {
  WalletTransactionsResponse({
    this.msg,
    this.response,
  });

  String msg;
  Response response;

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) => WalletTransactionsResponse(
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
    this.walletTransactions,
    this.walletBalance,
  });

  List<WalletTransaction> walletTransactions;
  String walletBalance;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    walletTransactions: json["walletTransactions"] == null ? null : List<WalletTransaction>.from(json["walletTransactions"].map((x) => WalletTransaction.fromJson(x))),
    walletBalance: json["walletBalance"] == null ? null : json["walletBalance"],
  );

  Map<String, dynamic> toJson() => {
    "walletTransactions": walletTransactions == null ? null : List<dynamic>.from(walletTransactions.map((x) => x.toJson())),
    "walletBalance": walletBalance == null ? null : walletBalance,
  };
}

class WalletTransaction {
  WalletTransaction({
    this.transactionId,
    this.walletId,
    this.transactionAmount,
    this.transactionAmountPrevious,
    this.transactionAmountBalance,
    this.transactionType,
    this.transactionCreatedDatetime,
    this.transactionRemark,
    this.transactionMethod,
    this.withdrawStatus,
    this.withdrawUpdateStatus,
  });

  String transactionId;
  String walletId;
  String transactionAmount;
  String transactionAmountPrevious;
  String transactionAmountBalance;
  String transactionType;
  DateTime transactionCreatedDatetime;
  String transactionRemark;
  String transactionMethod;
  dynamic withdrawStatus;
  dynamic withdrawUpdateStatus;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    transactionId: json["transaction_id"] == null ? null : json["transaction_id"],
    walletId: json["wallet_id"] == null ? null : json["wallet_id"],
    transactionAmount: json["transaction_amount"] == null ? null : json["transaction_amount"],
    transactionAmountPrevious: json["transaction_amount_previous"] == null ? null : json["transaction_amount_previous"],
    transactionAmountBalance: json["transaction_amount_balance"] == null ? null : json["transaction_amount_balance"],
    transactionType: json["transaction_type"] == null ? null : json["transaction_type"],
    transactionCreatedDatetime: json["transaction_created_datetime"] == null ? null : DateTime.parse(json["transaction_created_datetime"]),
    transactionRemark: json["transaction_remark"] == null ? null : json["transaction_remark"],
    transactionMethod: json["transaction_method"] == null ? null : json["transaction_method"],
    withdrawStatus: json["withdraw_status"],
    withdrawUpdateStatus: json["withdraw_update_status"],
  );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId == null ? null : transactionId,
    "wallet_id": walletId == null ? null : walletId,
    "transaction_amount": transactionAmount == null ? null : transactionAmount,
    "transaction_amount_previous": transactionAmountPrevious == null ? null : transactionAmountPrevious,
    "transaction_amount_balance": transactionAmountBalance == null ? null : transactionAmountBalance,
    "transaction_type": transactionType == null ? null : transactionType,
    "transaction_created_datetime": transactionCreatedDatetime == null ? null : transactionCreatedDatetime.toIso8601String(),
    "transaction_remark": transactionRemark == null ? null : transactionRemark,
    "transaction_method": transactionMethod == null ? null : transactionMethod,
    "withdraw_status": withdrawStatus,
    "withdraw_update_status": withdrawUpdateStatus,
  };

  static String TRANSACTION_TYPE_TOPUP = "topUp";

}
