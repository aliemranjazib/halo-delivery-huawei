import 'package:flutter/cupertino.dart';
import 'package:haloapp/models/top_up_transaction_model.dart';
import 'package:haloapp/models/wallet_transaction_model.dart';

class User {
  static ValueNotifier<WalletTransactionsResponse> walletTransactionsResponseNotifier =
      ValueNotifier<WalletTransactionsResponse>(null);
  static ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  User._privateConstructor();
  static final User _instance = User._privateConstructor();

  factory User() {
    return _instance;
  }

  String _userId;
  String _username;
  String _userEmail;
  String _userPhone;
  String _userPhoneCountryCode;
  String _userDOB;
  String _userToken;
  String _authToken;
  List _enabledOptions;
  bool _enableFood;
  bool _enableFrozen;
  bool _enablePharmacy;
  bool _enableGroceries;
  bool _enableFestival;
  WalletTransactionsResponse walletTransactionsResponse;
  TopUpTransactionResponse topUpTransactionResponse;
  String _userChatId;
  String _userRefCode;
  String _userRefLink;
  String _refTotalCommission;
  String _referLeaderShipBoard;

  void setUserData(
      {String userId,
      String username,
      String userEmail,
      String userPhone,
      String userPhoneCountryCode,
      String userDOB,
      String userToken,
      String authToken,
      String userChatId,
      String userRefCode,
      String userRefLink,
      String refTotalCommission,
      String referLeaderShipBoard,
      List enabledOptions,
      bool enableFood,
      bool enableFrozen,
      bool enablePharmacy,
      bool enableFestival,
      bool enableGroceries}) {
    this._userId = userId;
    this._username = username;
    this._userEmail = userEmail;
    this._userPhone = userPhone;
    this._userPhoneCountryCode = userPhoneCountryCode;
    this._userDOB = userDOB;
    this._userToken = userToken;
    this._authToken = authToken;
    this._enableFood = enableFood;
    this._enableFrozen = enableFrozen;
    this._enablePharmacy = enablePharmacy;
    this._enableGroceries = enableGroceries;
    this._enableFestival = enableFestival;
    this._enabledOptions = enabledOptions;
    this._userChatId = userChatId;
    this._userRefCode = userRefCode;
    this._userRefLink = userRefLink;
    this._refTotalCommission = refTotalCommission;
    this._referLeaderShipBoard = referLeaderShipBoard;
  }

  void resetUserData() {
    this._userId = null;
    this._username = null;
    this._userEmail = null;
    this._userPhone = null;
    this._userPhoneCountryCode = null;
    this._userDOB = null;
    this._userToken = null;
    this._authToken = null;
    this._enableFood = false;
    this._enableFrozen = false;
    this._enablePharmacy = false;
    this._enableGroceries = false;
    this._enableFestival = false;
    this._enabledOptions = [];
    this._userChatId = null;
    this._userRefCode = null;
    this._userRefLink = null;
    this._refTotalCommission = null;
    this._referLeaderShipBoard = null;
  }

  String getUsername() => _username;
  String getUserId() => _userId;
  String getUserEmail() => _userEmail;
  String getUserPhone() => _userPhone;
  String getUserPhoneCountryCode() => _userPhoneCountryCode;
  String getUserDOB() => _userDOB;
  String getUserToken() => _userToken;
  String getAuthToken() => _authToken;
  String getUserChatId() => _userChatId;
  String getUserRefCode() => _userRefCode;
  String getUserRefLink() => _userRefLink;
  String getRefTotalCommission() => _refTotalCommission;
  String getRefLeaderBoard() => _referLeaderShipBoard;
  bool getEnableFoodStatus() => _enableFood;
  bool getEnableFrozenStatus() => _enableFrozen;
  bool getEnablePharmacyStatus() => _enablePharmacy;
  bool getEnableGroceriesStatus() => _enableGroceries;
  bool getEnabledFestivalStatus() => _enableFestival;
  List getEnabledOptions() => _enabledOptions;
  WalletTransactionsResponse getWalletTransactionsResponse() => walletTransactionsResponse;
  TopUpTransactionResponse getTopUpTransactionResponse() => topUpTransactionResponse;

  void setUserToken(String token) {
    this._userToken = token;
  }

  void setEmail(String email) {
    this._userEmail = email;
  }

  void setUsername(String userName) {
    this._username = userName;
  }

  void setRefTotalCommission(String commission) {
    this._refTotalCommission = commission;
  }

  void setEwalletTransaction(WalletTransactionsResponse walletTransactionsResponse) {
    walletTransactionsResponseNotifier.value = walletTransactionsResponse;
    this.walletTransactionsResponse = walletTransactionsResponse;
  }

  void setTopUpTransaction(TopUpTransactionResponse topUpTransactionResponse) {
    this.topUpTransactionResponse = topUpTransactionResponse;
  }
}
