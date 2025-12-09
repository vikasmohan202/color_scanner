import 'package:ralpal/utils/constants.dart';
import 'package:ralpal/utils/shared_pref.dart';

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
