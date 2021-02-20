import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class ReceiverPage extends StatefulWidget {
  String _qrJson;

  ReceiverPage(this._qrJson);

  @override
  _ReceiverPageState createState() => _ReceiverPageState(_qrJson);
}

class _ReceiverPageState extends State<ReceiverPage> {
  Map _qrData;
  List<DataRow> fields = List<DataRow>();

  _ReceiverPageState(args) {
    _qrData = json.decode(args);
    fields.add(DataRow(
      false,
      key: 'location',
      readOnly: true,
    ));
  }

  Future<dynamic> makeJsonData() {
    Map object = Map();
    int count = 0;
    for (int i = 0; i < fields.length; i++) {
      Map val = fields[i].getData();
      if (val['key'].isEmpty || val['value'].isEmpty) {
        count += 1;
      }
      object[val['key']] = val['value'];
    }
    print(object);
    if (count == 0) {
      return http.post(
        Helper.url + '/sendMoreProps',
        body: json.encode({
          'product_id': _qrData['product_id'],
          'enc_props': json.encode(object),
          'owner': _qrData['sender'],
        }),
      );
    }
    return Future.delayed(Duration(seconds: 0), () => 'error');
  }

  Future<dynamic> rejection() {
    return http.post(
      Helper.url + '/reject',
      body: json.encode(
        {
          'owner': _qrData['sender'],
          'product_id': _qrData['product_id'],
          'person': 'receiver',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Receiver Hub",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 12),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue[100],
                  height: MediaQuery.of(context).size.height / 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        _qrData['product'],
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(
                        "Quantity: " + _qrData['quantity'],
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  // width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          child: TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Tab(
                                text: "Add props",
                              ),
                              Tab(
                                text: "Sender Info",
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          width: MediaQuery.of(context).size.width,
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // DataRow(),
                                    Column(
                                      children: List.generate(
                                          fields.length, (int index) => fields[index]),
                                    ),
                                    ButtonTheme(
                                      minWidth: 100,
                                      child: RaisedButton(
                                        onPressed: () {
                                          setState(() {
                                            fields.insert(0, DataRow(true));
                                          });
                                        },
                                        child: Text(
                                          "Add another field",
                                          style: TextStyle(fontSize: 17, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ButtonTheme(
                                          minWidth: 100,
                                          child: RaisedButton(
                                            onPressed: () {
                                              Fluttertoast.showToast(
                                                msg: "Waiting to send...",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                              makeJsonData().then((val) {
                                                if (val == 'error') {
                                                  Fluttertoast.showToast(
                                                    msg: "There's some error!",
                                                    toastLength: Toast.LENGTH_LONG,
                                                    gravity: ToastGravity.BOTTOM,
                                                  );
                                                } else {
                                                  print(val.body);
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Added Successfully! Wait for sender to confirm",
                                                    toastLength: Toast.LENGTH_LONG,
                                                    gravity: ToastGravity.BOTTOM,
                                                  );
                                                }

                                                // maybe close page or something?
                                              });
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(fontSize: 17, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        ButtonTheme(
                                          minWidth: 100,
                                          buttonColor: Colors.red,
                                          child: RaisedButton(
                                            onPressed: () {
                                              // call rejection function
                                              rejection().then((val) {
                                                // TODO
                                                // redirect to products page
                                              });
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.white,
                                                  backgroundColor: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Text("Senders stufff"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataRow extends StatelessWidget {
  final _key = TextEditingController();
  final _value = TextEditingController();
  final bool allowNull;
  final bool readOnly;

  DataRow(this.allowNull, {String key = '', this.readOnly = false}) {
    _key.text = key;
  }

  Map<String, String> getData() {
    String key = _key.text;
    String value = _value.text;
    return {'key': key, 'value': value};
  }

  String valid(String input) {
    if (input.isNotEmpty) {
      return null;
    } else {
      return 'Cannot be kept blank';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            // flex: 3,
            // fit: FlexFit.loose,
            child: TextFormField(
              controller: _key,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: 'Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
          Flexible(
            // flex: 3,
            // fit: FlexFit.loose,
            child: TextFormField(
              controller: _value,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: 'Value',
                errorText: valid(_value.text),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
