


import 'package:color_scanner/utils/constants.dart';
import 'package:color_scanner/utils/shared_pref.dart';

class ApiBase {
  String accessToken = '';
  String refreshToken = '';
  String userId = '';
  ApiBase() {
    accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    refreshToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;
    userId = SharedPrefUtil.getValue(userIdPref, "") as String;
    print(accessToken);
  }
}
