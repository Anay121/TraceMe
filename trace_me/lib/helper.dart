import 'package:flutter_session/flutter_session.dart';

class Helper {
  static final String url = 'https://50d519a05a18.ngrok.io';
}

class Session {
  void setter(dynamic jsonVal) async {
    await FlutterSession().set("userid", jsonVal['userid']);
    await FlutterSession().set("JWTAccess", jsonVal['JWTAccessToken']);
    await FlutterSession().set("JWTRefresh", jsonVal['JWTRefreshToken']);
  }

  Future<String> getter(String key) async {
    String val = await FlutterSession().get(key);
    return val;
  }
}
