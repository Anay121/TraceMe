import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_session/flutter_session.dart';

var orange = Color.fromRGBO(255, 91, 53, 1);
var darker = Color(0xFFCB672F);
var myOrangeButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(darker),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    )));

class Helper {
  static final String url = 'http://1b7d12b5af8a.ngrok.io';
}

class Session {
  void setter(dynamic jsonVal) async {
    print(jsonVal);
    await FlutterSession().set("userid", jsonVal['userid']);
    await FlutterSession().set("JWTAccess", jsonVal['JWTAccessToken']);
    await FlutterSession().set("JWTRefresh", jsonVal['JWTRefreshToken']);
    await FlutterSession().set("role", jsonVal['role']);
  }

  Future<String> getter(String key) async {
    String val = await FlutterSession().get(key);
    return val;
  }
}

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
              title: Text('Home'),
              trailing: Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, 'DisplayProductsPage');
              }),
          ListTile(
            title: Text('Profile'),
            trailing: Icon(Icons.person_rounded),
            onTap: () async {
              String val = await Session().getter('userid');
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, 'UserInfoPage',
                  arguments: val);
            },
          ),
          ListTile(
            title: Text('Scan'),
            trailing: Icon(Icons.qr_code_scanner_rounded),
            onTap: () => Navigator.popAndPushNamed(context, 'QRScanPage'),
          ),
          ListTile(
            title: Text('Search top stakeholders'),
            trailing: Icon(Icons.people_rounded),
            onTap: () => Navigator.popAndPushNamed(context, 'RankingPage'),
          ),
          ListTile(
            title: Text('Logout'),
            trailing: Icon(Icons.logout),
            onTap: () async {
              Session().setter(
                  {'userid': "", 'JWTAccessToken': "", 'JWTRefreshToken': ""});
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (router) => false);
            },
          )
        ],
      ),
    );
  }
}

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double _xScaling = size.width / 300;
    final double _yScaling = size.height / 300;
    path.lineTo(387 * _xScaling, 34.84800000000001 * _yScaling);
    path.cubicTo(
      387 * _xScaling,
      132.139 * _yScaling,
      269.574 * _xScaling,
      291.21 * _yScaling,
      85.83600000000001 * _xScaling,
      240.132 * _yScaling,
    );
    path.cubicTo(
      -21.436000000000007 * _xScaling,
      210.31099999999998 * _yScaling,
      -53.003 * _xScaling,
      146.24599999999998 * _yScaling,
      -294.76300000000003 * _xScaling,
      54.793000000000006 * _yScaling,
    );
    path.cubicTo(
      -385.251 * _xScaling,
      -27.418000000000006 * _yScaling,
      -137.3204 * _xScaling,
      -222 * _yScaling,
      49.227000000000004 * _xScaling,
      -222 * _yScaling,
    );
    path.cubicTo(
      235.774 * _xScaling,
      -222 * _yScaling,
      387 * _xScaling,
      -87.252 * _yScaling,
      387 * _xScaling,
      34.84800000000001 * _yScaling,
    );
    path.cubicTo(
      387 * _xScaling,
      34.84800000000001 * _yScaling,
      387 * _xScaling,
      34.84800000000001 * _yScaling,
      387 * _xScaling,
      34.84800000000001 * _yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class mainPageBezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double _xScaling = size.width / 414;
    final double _yScaling = size.height / 390;
    path.lineTo(544 * _xScaling, 145.848 * _yScaling);
    path.cubicTo(
      544 * _xScaling,
      243.139 * _yScaling,
      426.574 * _xScaling,
      402.21 * _yScaling,
      242.836 * _xScaling,
      351.132 * _yScaling,
    );
    path.cubicTo(
      135.564 * _xScaling,
      321.311 * _yScaling,
      103.997 * _xScaling,
      257.246 * _yScaling,
      -137.763 * _xScaling,
      165.793 * _yScaling,
    );
    path.cubicTo(
      -228.251 * _xScaling,
      83.582 * _yScaling,
      19.6796 * _xScaling,
      -111 * _yScaling,
      206.227 * _xScaling,
      -111 * _yScaling,
    );
    path.cubicTo(
      392.774 * _xScaling,
      -111 * _yScaling,
      544 * _xScaling,
      23.748 * _yScaling,
      544 * _xScaling,
      145.848 * _yScaling,
    );
    path.cubicTo(
      544 * _xScaling,
      145.848 * _yScaling,
      544 * _xScaling,
      145.848 * _yScaling,
      544 * _xScaling,
      145.848 * _yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
