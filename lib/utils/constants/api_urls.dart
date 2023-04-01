import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'dart:io' show Platform;

class APIUrls {
  static const PRODUCTION_ENVIRONMENT = 1;
  static const STAGING_ENVIRONMENT = 2;

  //Switch this to PRODUCTION_ENVIRONMENT when generate Production app
  static const ENVIRONMENT = PRODUCTION_ENVIRONMENT;

  static get uri {
    if (ENVIRONMENT == STAGING_ENVIRONMENT) {
      return 'https://stagingapi.halo.express';
    } else {
      return 'https://api.halo.express';
    }
  }

  static get _uri {
    if (ENVIRONMENT == STAGING_ENVIRONMENT) {
      return 'https://stagingapi.halo.express';
    } else {
      return 'https://api.halo.express';
    }
  }

  static get _userUri {
    if (ENVIRONMENT == STAGING_ENVIRONMENT) {
      return "https://staginguserapi.halo.express";
    } else {
      return 'https://userapi.halo.express';
    }
  }

  static get _foodUri {
    if (ENVIRONMENT == STAGING_ENVIRONMENT) {
      return "https://stagingfoodapi.halo.express";
    } else {
      return 'https://foodapi.halo.express';
    }
  }

  static const _apiKey = 'qnwwMnArPNTbdg7phWPt';
  static const _apiKeyWeb = "qnwwMnArPNTbdg7phWPtweb";
  static const _iosFoodApiKey = 'sV54LU6kjuDKBX2Lz1Ya';
  static const _androidFoodApiKey = 'swDW360noNSAVXw4Xmin';
//  static const _googleAPIKey = 'AIzaSyB8-ypkZ-83OMzbMUGrJWa2v-XBIqQWHdo';
  static const _googleAPIKey = 'AIzaSyAg3RmeUBhk-VJ6hU5fW7twSwuR7wwTwn4';
  static const _huaweiAPIKey =
      'CgB6e3x9uNKV24tyfTKYoKihr6SjVYptbsFVZg8RfKPNRHkNbZfvhp6A5f1vZI6bilngw6ZpIHga/wsAcu7dnLTd';

  static const _checkAppUpdate = '/user/checkVersion';
  static const _login = '/user/login';
  static const _socialLogin = '/user/socialLogin';
  static const _socialUpdatePhoneNumber = '/user/socialUpdatePhoneNumber';
  static const _socialBindOldAccount = '/user/socialBindOldAccount';
  static const _updateProfile = '/user/updateProfile';
  static const _changePhoneNumber = '/user/changePhoneNumber';

  static const _register = '/user/register';
  static const _smsVerification = '/user/verification';
  static const _resendVerificationCode = '/user/resendVerificationCode';
  static const _forgotPassword = '/user/forgotPassword';
  static const _changePassword = '/user/changePassword';
  static const _homeInfo = '/Consumer/header/getHeaders';
  static const _appConfig = '/user/config';
  static const _mainBanner = '/user/mainBanner';
  static const _reviewBanner = '/user/reviewBanner';
  static const _supportQuestion = '/user/supportQuestion';
  static const _removeAccount = '/user/removeAccount';

  static const _availableBookingDates = '/Consumer/date/available';
  static const _getDistancePrice = '/Consumer/price/distance';
  static const _createBooking = '/Consumer/booking/createBooking';
  static const _confirmBooking = '/Consumer/booking/confirmBooking';
  static const _validateCoupon = '/Consumer/coupon/validateCoupon';
  static const _couponList = '/Consumer/coupon/couponList';

  static const _uploadPhoto = '/upload/remarks';
  static const _recentAddresses = '/Consumer/booking/recentAddress';

  static const _bookingHistory = '/Consumer/booking/bookingHistory';
  static const _bookingDetails = '/Consumer/booking/getBookingDetail';
  static const _cancelBooking = '/Consumer/booking/cancel';
  static const _rate = '/Consumer/booking/rate';
  static const _tracking = '/Consumer/booking/liveTracking';
  static const _notificationList = '/Consumer/notification/list';
  static const _allActivity = '/Consumer/booking/allActivity';
  static const _recentActivity = '/Consumer/booking/recentActivity';
  static const _bookingRefund = '/Consumer/booking/refund';

  // Food
  static const _nearbyShops = '/Consumer/shop/nearby';
  static const _nearbyFeaturedShops = '/Consumer/shop/nearbyFeature';
  static const _nearbySearchShops = '/Consumer/shop/nearbySearch';
  static const _nearbyPromoItem = '/Consumer/shop/nearbyPromoItem';
  static const _shopDetails = '/Consumer/shop/detail';
  static const _zoneList = "/Consumer/zone/list";
  static const _shopReviews = '/Consumer/shop/shopReview';

  static const _calculateFoodOrder = '/Consumer/order/calculate';
  static const _createFoodOrder = '/Consumer/order/create';
  static const _confirmFoodOrder = '/Consumer/order/confirm';
  static const _foodValidateCoupon = '/Consumer/coupon/validateCoupon';
  static const _foodCouponList = '/Consumer/coupon/couponList';
  static const _foodOrderHisotry = '/Consumer/order/history';
  static const _foodOrderDetails = '/Consumer/order/detail';
  static const _foodRating = '/Consumer/order/rate';
  static const _foodAddFavShop = '/Consumer/shop/addFavouriteShop';
  static const _foodRemoveFavShop = '/Consumer/shop/removeFavouriteShop';

  //eWallet
  static const _walletTopUpTransaction = "/Wallet/topupTransaction";
  static const _walletTransaction = "/Wallet/transaction";
  static const _walletTopUp = "/Wallet/topup";
  static const _walletTopUpCalculation = "/Wallet/topupCalculation";
  static const _walletCheckStatus = "/payment/billPlzCheckStatus";
  static const _walletTopUpPaymentMethodList =
      "/Consumer/booking/getAvailableOnlinePaymentMethod";

  //Referrals
  static const _referralDetails = "/user/referralSummary";

  //Change payment
  static const _availableOnlinePaymentMethod =
      "/Consumer/booking/getAvailableOnlinePaymentMethod";
  static const _updatePaymentCalculate =
      "/Consumer/order/updatePaymentMethodCalculate";
  static const _updatePaymentMethod = "/Consumer/order/updatePaymentMethod";

  Future<Map<String, String>> getHeader() async {
    String version = await PackageInfoService().getAppBuildNumber();
    String languageCode = await SharedPrefService().getLanguage();
    String platform = (Platform.isIOS) ? 'ios' : 'android';
    String authToken = User().getAuthToken();

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'platform': platform,
      'language': languageCode,
      'version': version,
      // authToken != null ? 'Authorization' : authToken: '',
    };
  }

  String getApiKey() => _apiKey;

  String getWebApiKey() => _apiKeyWeb;

  String getFoodApiKey() {
    if (Platform.isIOS) {
      return _iosFoodApiKey;
    } else if (Platform.isAndroid) {
      return _androidFoodApiKey;
    } else {
      return '';
    }
  }

  String getHuaweiAPIKey() => _huaweiAPIKey;
  String getGoogleAPIKey() => _googleAPIKey;
  String getLoginUrl() => _userUri + _login;
  String getSocialLoginUrl() => _userUri + _socialLogin;
  String getSocialUpdatePhoneNumberUrl() => _userUri + _socialUpdatePhoneNumber;
  String getSocialBindOldAccountUrl() => _userUri + _socialBindOldAccount;
  String getUpdateProfileUrl() => _userUri + _updateProfile;
  String getChangePhoneUrl() => _userUri + _changePhoneNumber;

  String getCheckAppUpdateUrl() => _userUri + _checkAppUpdate;
  String getRegisterUrl() => _userUri + _register;
  String getSmsVerificationUrl() => _userUri + _smsVerification;
  String getResendVerificationCodeUrl() => _userUri + _resendVerificationCode;
  String getForgotPasswordUrl() => _userUri + _forgotPassword;
  String getChangePasswordUrl() => _userUri + _changePassword;
  String getAppConfigUrl() => _userUri + _appConfig;
  String getRemoveAccountUrl() => _userUri + _removeAccount;

  String getSaveAddressUrl() => _userUri + '/address/addAddress';
  String getEditAddressUrl() => _userUri + '/address/editAddress';
  String getRemoveAddressUrl() => _userUri + '/address/removeAddress';
  String getSavedAddressListUrl() => _userUri + '/address/addressList';
  String getNearbySavedAddresstUrl() => _userUri + '/address/nearbyAddress';
  String getHomeBannerUrl() => _userUri + _mainBanner;
  String getReviewBannerUrl() => _userUri + _reviewBanner;
  String getUserSupportUrl() => _userUri + _supportQuestion;
  String getUserReferralDetailUrl() => _userUri + _referralDetails;

  String getAvailableBookingDatesUrl() => _uri + _availableBookingDates;
  String getDistancePriceUrl() => _uri + _getDistancePrice;
  String getCreateBookingUrl() => _uri + _createBooking;
  String getConfirmBookingUrl() => _uri + _confirmBooking;
  String getValidateCouponUrl() => _uri + _validateCoupon;
  String getCouponListUrl() => _uri + _couponList;

  String getUploadPhotoUrl() => _uri + _uploadPhoto;
  String getRecentAddressesUrl() => _uri + _recentAddresses;

  String getBookingHistoryUrl() => _uri + _bookingHistory;
  String getBookingDetailsUrl() => _uri + _bookingDetails;
  String getCancelBookingUrl() => _uri + _cancelBooking;
  String getRateRiderUrl() => _uri + _rate;
  String getTrackingInfoUrl() => _uri + _tracking;
  String getNotificationListUrl() => _uri + _notificationList;
  String getRecentActivityUrl() => _uri + _recentActivity;
  String getAllRecentActivityUrl() => _uri + _allActivity;
  String getBookingRefundUrl() => _uri + _bookingRefund;

  // Food
  String getHomeInfo() => _foodUri + _homeInfo;
  String getNearbyShopUrl() => _foodUri + _nearbyShops;
  String getNearbyFeaturedShopUrl() => _foodUri + _nearbyFeaturedShops;
  String getNearbyPromoItemUrl() => _foodUri + _nearbyPromoItem;

  String getShopReview() => _foodUri + _shopReviews;

  String getNearbySearchShopUrl() => _foodUri + _nearbySearchShops;

  String getShopDetailsUrl() => _foodUri + _shopDetails;
  String getZoneListUrl() => _uri + _zoneList;

  String getCalculateFoodOrderUrl() => _foodUri + _calculateFoodOrder;
  String getCreateFoodOrderUrl() => _foodUri + _createFoodOrder;
  String getConfirmFoodOrderUrl() => _foodUri + _confirmFoodOrder;
  String getFoodValidateCouponUrl() => _foodUri + _foodValidateCoupon;
  String getFoodCouponListUrl() => _foodUri + _foodCouponList;

  String getFoodOrderHistoryUrl() => _foodUri + _foodOrderHisotry;
  String getFoodOrderDetailsUrl() => _foodUri + _foodOrderDetails;
  String getFoodRatingUrl() => _foodUri + _foodRating;
  String getFoodAddFavShopUrl() => _foodUri + _foodAddFavShop;
  String getFoodRemoveFavShopUrl() => _foodUri + _foodRemoveFavShop;

  //Ewallet
  String getWalletTopUpTransaction() => _userUri + _walletTopUpTransaction;
  String getWalletTransaction() => _userUri + _walletTransaction;
  String getWalletTopUp() => _userUri + _walletTopUp;
  String getWalletTopUpCalculation() => _userUri + _walletTopUpCalculation;
  String getWalletCheckStatus() => _userUri + _walletCheckStatus;
  String getTopUpPaymentMethodList() => _uri + _walletTopUpPaymentMethodList;

  //Change payment
  String getAvailableOnlineMethods() => _uri + _availableOnlinePaymentMethod;
  String getUpdatePaymentCalculate() => _foodUri + _updatePaymentCalculate;
  String getUpdatePaymentMethods() => _foodUri + _updatePaymentMethod;
}
