import 'package:flutter_session/flutter_session.dart';

class Helper {
  static final String url = 'http://334adbfcb5ab.ngrok.io';
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
