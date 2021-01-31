import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';

// class QrScanPage extends StatefulWidget {
//   @override
//   _QrScanPageState createState() => _QrScanPageState();
// }

class QrScanPage extends StatelessWidget {
  Future<dynamic> doScan() async {
    await Permission.camera.request();
    String cameraScanResult = await scanner.scan();

    return cameraScanResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
          child: Column(
            children: [
              FutureBuilder(
                future: doScan(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Navigator.popAndPushNamed(context, 'ReceiverStatusPage',
                        arguments: snapshot.data);
                    return Text(snapshot.data.toString());
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
