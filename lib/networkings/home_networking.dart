import 'dart:io';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/promo_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/utils/filehelper.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'dart:convert';
import '../utils/constants/api_urls.dart';
import 'package:http/http.dart' as HTTP;

class HomeNetworking {
  Future<List<PromoModel>> getHomeInfo(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getHomeInfo(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      List<PromoModel> promos = _delegateHomeData(decodedData['return']);
      return promos;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getHomeInfo Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  List<PromoModel> _delegateHomeData(Map<String, dynamic> returnData) {
    List<PromoModel> promos = [];

    List<dynamic> headerArr = returnData['headers'];

    if (headerArr != null) {
      if (headerArr.length > 0) {
        for (int i = 0; i < headerArr.length; i++) {
          Map<String, dynamic> header = headerArr[i];

          PromoModel promo = PromoModel(
            id: header['promo_id'] ?? '',
            actionUrl: header['promo_action_url'] ?? '',
            name: header['promo_name'] ?? '',
            imageUrl: header['promo_image_url'] ?? '',
            status: header['promo_status'] ?? '',
            actionType: header['promo_action_type'] ?? '',
          );

          promos.add(promo);
        }
      }
    }

    return promos;
  }

  static initAppConfig([position]) async {
    String authToken = User().getAuthToken();

    try {
      Map<String, String> headers = await APIUrls().getHeader();
      if (authToken != null) {
        headers.addAll({
          "Authorization": authToken,
        });
      }

      HTTP.Response response = await NetworkingService().postRequest(
          APIUrls().getAppConfigUrl(),
          position != null
              ? {
                  "data": {
                    'lat': position['latitude'],
                    'lng': position['longitude']
                  }
                }
              : {},
          headers);

      // String data = await response.transform(utf8.decoder).join();
      var decodedData = jsonDecode(response.body);
      print(decodedData);
      AppConfig().fromJson(decodedData['response']);
      print('### RESET');

      return;
    } catch (e) {
      print(e);
    }

    String jsonContent;
    String url =
        'https://halorider.oss-ap-southeast-3.aliyuncs.com/appConfig/consumer_default_config.json';

    try {
      var bodyRaw = (await HTTP.get(Uri.parse(url))).bodyBytes;
      jsonContent = Utf8Decoder().convert(bodyRaw);
      print('http success');
    } catch (err) {
      jsonContent =
          await FileHelper.getFileData("assets/configs/consumer_config.json");
      print('http fail');
    }

    print(jsonContent);

    try {
      // AppConfig().configJson(jsonDecode(jsonContent));
      var decodedData = jsonDecode(jsonContent);
      AppConfig().fromJson(decodedData['response']);
    } catch (e) {
      jsonContent =
          await FileHelper.getFileData("assets/configs/consumer_config.json");
      AppConfig().configJson(jsonDecode(jsonContent));
      print(e);
    }
  }
}
