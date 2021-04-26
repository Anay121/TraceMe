import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:trace_me/helper.dart';

class QrScanPage extends StatelessWidget {
  Future<dynamic> doScan() async {
    await Permission.camera.request();
    String cameraScanResult = await scanner.scan();
    return cameraScanResult;
  }

  Future<dynamic> getStatus(String _owner, String _prodId) async {
    return http.post(Helper.url + '/transactionInfo',
        body: json.encode({
          'username': _owner,
          'product_id': _prodId,
        }));
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
                    Map val = json.decode(snapshot.data);
                    if (val['type'] == 'transfer') {
                      getStatus(val['sender'], val['product_id'])
                          .then((returnValue) {
                        // if status is 1, go to receiver page otherwise redirect to status page
                        // print('${json.decode(returnValue.body)["status"]} statuscode');
                        if (json.decode(returnValue.body)['status'] == 1) {
                          Navigator.popAndPushNamed(context, 'ReceiverPage',
                              arguments: snapshot.data);
                        } else {
                          val['status'] =
                              json.decode(returnValue.body)['status'];
                          Navigator.popAndPushNamed(
                              context, 'StatusReceiverPage',
                              arguments: json.encode(val));
                        }
                      });
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popAndPushNamed(
                          context,
                          'TraceProductPage',
                          arguments: int.parse(val['product_id']),
                        );
                      });
                    }
                    return Text('Just a Moment...');
                  } else {
                    return spinkit;
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
