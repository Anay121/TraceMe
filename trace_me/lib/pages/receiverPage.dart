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

  Future<dynamic> makeJsonData() async {
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
    String loggedUser = await Session().getter('userid');
    if (count == 0) {
      return http.post(
        Helper.url + '/sendMoreProps',
        body: json.encode({
          'product_id': _qrData['product_id'],
          'enc_props': json.encode(object),
          'owner': _qrData['sender'],
          'new': loggedUser,
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

  void showAlert(String title, String content, {void onYesPress()}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ButtonTheme(
              minWidth: 100,
              child: ElevatedButton(
                onPressed: () {
                  onYesPress();
                },
                child: Text(
                  "Yes",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
            ButtonTheme(
              minWidth: 100,
              buttonColor: Colors.red,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ])
        ],
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
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 12,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                Container(
                  alignment: Alignment.center,
                  color: orange,
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
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  // width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          child: TabBar(
                            labelColor: darker,
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
                                    CircleAvatar(
                                      backgroundColor: darker,
                                      radius: 30,
                                      child: IconButton(
                                        icon: Icon(Icons.add),
                                        color: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            fields.insert(0, DataRow(true));
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height / 40),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ButtonTheme(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              showAlert(
                                                  'Confirm', 'Are you sure you want to confirm?',
                                                  onYesPress: () {
                                                Fluttertoast.showToast(
                                                  msg: "Waiting to send...",
                                                  toastLength: Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                );
                                                Navigator.pop(context);
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
                                                    Navigator.pushReplacementNamed(
                                                        context, 'DisplayProductsPage');
                                                  }
                                                  // maybe close page or something?
                                                });
                                              });
                                            },
                                            label: Text(
                                              "Confirm",
                                              style: TextStyle(fontSize: 17, color: Colors.white),
                                            ),
                                            icon: Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ButtonTheme(
                                          buttonColor: Colors.red,
                                          child: ElevatedButton.icon(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<Color>(Colors.red)),
                                            onPressed: () {
                                              // call rejection function
                                              rejection().then((val) {
                                                Navigator.pushReplacementNamed(
                                                    context, 'DisplayProductsPage');
                                              });
                                            },
                                            label: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                            icon: Icon(
                                              Icons.cancel,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height / 40),
                                    ButtonTheme(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, 'TraceProductPage',
                                                arguments: int.parse(_qrData['product_id']));
                                          },
                                          child: Text(
                                            "Product Trace",
                                            style: TextStyle(fontSize: 17, color: Colors.white),
                                          ),
                                        ),
                                        buttonColor: darker)
                                  ],
                                ),
                              ),
                              Container(
                                child: ButtonTheme(
                                  minWidth: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        'UserInfoPage',
                                        arguments: _qrData['sender'],
                                      );
                                    },
                                    child: Text(
                                      "View Sender Information",
                                      style: TextStyle(fontSize: 17, color: Colors.white),
                                    ),
                                  ),
                                  buttonColor: Color(0xFFD3D3D3),
                                ),
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
  bool _validateValue = false;

  DataRow(this.allowNull, {String key = '', this.readOnly = false}) {
    _key.text = key;
  }

  Map<String, String> getData() {
    String key = _key.text;
    String value = _value.text;
    return {'key': key, 'value': value};
  }

  void valid(String input) {
    if (input.isNotEmpty) {
      _validateValue = true;
    } else {
      _validateValue = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      height: 50,
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
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Flexible(
            // flex: 3,
            // fit: FlexFit.loose,
            child: TextFormField(
              controller: _value,
              decoration: InputDecoration(
                hintText: 'Value',
                suffixText: '*',
                suffixStyle: TextStyle(
                  color: Colors.red,
                ),
                // errorText: _validateValue ? '' : 'Cannot be kept empty',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
