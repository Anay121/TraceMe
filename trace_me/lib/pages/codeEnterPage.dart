import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trace_me/helper.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getCodeData(String code) {
  return http.post(
    Helper.url + '/getCodeProps',
    body: json.encode({'code': code}),
  );
}

Future<dynamic> getStatus(String _owner, String _prodId) async {
  return http.post(
    Helper.url + '/transactionInfo',
    body: json.encode({
      'username': _owner,
      'product_id': _prodId,
    }),
  );
}

class CodeEnterPage extends StatefulWidget {
  @override
  _CodeEnterPageState createState() => _CodeEnterPageState();
}

class _CodeEnterPageState extends State<CodeEnterPage> {
  final codeController = TextEditingController();
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
    // Map<String, String> valu;
    return Scaffold(
      drawer: MenuDrawer(),
      body: Column(children: [
        ClipPath(
          clipper: BezierClipper(),
          child: Container(
            color: orange,
            height: height,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 30),
          child: Container(
            height: 400,
            width: 400,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter the Code',
                    suffixText: '*',
                    errorText: showError ? 'Please enter a code' : '',
                    suffixStyle: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  controller: codeController,
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 13,
                  child: ElevatedButton(
                    onPressed: () {
                      if (codeController.text != '') {
                        showError = false;
                        getCodeData(codeController.text).then((value) {
                          print(value.body);
                          Map val;
                          val = json.decode(value.body, reviver: (key, value) {
                            // value = value.toString();
                            // print(value)
                            return value;
                          });
                          print(val);
                          getStatus(val['sender'], val['product_id']).then((returnValue) {
                            if (json.decode(returnValue.body)['status'] == 1) {
                              // print('issa 1');
                              Navigator.popAndPushNamed(context, 'ReceiverPage', arguments: value.body);
                            } else {
                              val['status'] = json.decode(returnValue.body)['status'];
                              // print('issa notta 1');
                              Navigator.popAndPushNamed(context, 'StatusReceiverPage', arguments: json.encode(val));
                            }
                          });
                          return Text('Just a Moment...');
                        });
                      } else {
                        showError = true;
                      }
                    },
                    child: Text(
                      'CONFIRM CODE',
                    ),
                    style: myOrangeButtonStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
