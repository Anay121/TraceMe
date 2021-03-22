import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

var args = List<int>();
List<DataRow> fields = List<DataRow>();
TextEditingController quantLeft = new TextEditingController();

class SplitProductPage extends StatefulWidget {
  SplitProductPage(List<int> arg) {
    args = arg;
    print(args);

    //2 complusory for split
    fields.add(DataRow());
    fields.add(DataRow());
  }

  @override
  _SplitProductState createState() => _SplitProductState();
}

class _SplitProductState extends State<SplitProductPage> {
  bool _validateError = false;

  Future<dynamic> splitProduct(List quants) async {
    // List object = List();
    // for (int i = 0; i < fields.length; i++) {
    //   object.add(fields[i].getData());
    // }
    // print(object);

    String val = await Session().getter('userid');
    return http.post(Helper.url + '/split',
        body: json.encode({"product_id": args[0], "quantities": quants, "user_id": val}));
  }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
    TextStyle keyStyle = TextStyle(color: darker, fontSize: MediaQuery.of(context).size.width / 23);
    TextStyle valueStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 23);
    List object = List();
    List<int> lint = List<int>();
    int objSum;

    quantLeft.text = args[1].toString();

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
            child: Column(
              children: [
                Text(
                  'SPLIT PRODUCT',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15,
                      fontWeight: FontWeight.bold),
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        new Text("TOTAL QUANTITY", style: keyStyle),
                        new Text("${args[1]}", style: valueStyle)
                      ]),
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      // Row(
                      // //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // //     children: [
                      // //       new Text("QUANTITY LEFT", style: keyStyle),
                      // //       new TextField(
                      // //           enabled: false, controller: quantLeft),
                      // //     ]),
                      // // SizedBox(height: MediaQuery.of(context).size.height / 40),
                      Column(
                        children: List.generate(fields.length, (int index) => fields[index]),
                      ),
                      CircleAvatar(
                        backgroundColor: darker,
                        radius: 30,
                        child: IconButton(
                          icon: Icon(Icons.add),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              fields.insert(0, DataRow());
                            });
                          },
                        ),
                      ),
                    ])
              ],
            ),
          ),
        ),
        Expanded(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 12,
                child: TextButton(
                  onPressed: () => {
                    for (int i = 0; i < fields.length; i++) {object.add(fields[i].getData())},
                    // print(object),
                    for (var i in object) {lint.add(int.parse(i))},
                    // print(lint),
                    objSum = lint.reduce((a, b) => a + b),
                    print(objSum),
                    if (objSum == args[1])
                      {
                        splitProduct(object).then((val) {
                          // check validation
                          print(val.statusCode);
                          if (val.statusCode == '401') {
                            setState(() {
                              _validateError = true;
                            });
                          }
                          // redirect with params
                          else {
                            Navigator.popAndPushNamed(context, 'DisplayProductsPage');
                          }
                        }),
                      }
                    else if (objSum < args[1])
                      {
                        object.add((args[1] - objSum).toString()),
                        splitProduct(object).then((val) {
                          // check validation
                          print(val.statusCode);
                          if (val.statusCode == '401') {
                            setState(() {
                              _validateError = true;
                            });
                          }
                          // redirect with params
                          else {
                            Navigator.popAndPushNamed(context, 'DisplayProductsPage');
                          }
                        }),
                      }
                    else
                      {
                        showAlertDialog(context),
                      }
                  },
                  child: Text("SPLIT PRODUCT"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(darker),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ))),
                ),
              )),
        ),
      ]),
    );
  }
}

class DataRow extends StatelessWidget {
  var _value = TextEditingController();
  DataRow() {
    // _value.addListener(changeQuantityLeft());
  }

  String getData() {
    String value = _value.text;
    return value;
  }

  changeQuantityLeft() {
    List obj = List();
    List lint;
    var sum;
    for (int i = 0; i < fields.length; i++) {
      obj.add(fields[i].getData());
    }
    // print(obj),
    for (var i in obj) {
      lint.add(int.parse(i));
    }
    // print(lint),
    sum = lint.reduce((a, b) => a + b);

    quantLeft.text = (args[1] - sum).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      height: 50,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Flexible(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'QUANTITY',
              suffixText: '*',
              suffixStyle: TextStyle(
                color: Colors.red,
              ),
            ),
            controller: _value,
            onChanged: (text) {
              changeQuantityLeft();
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          color: Colors.grey,
          onPressed: () {
            _value.text = (int.parse(_value.text) + 1).toString();
          },
        ),
        IconButton(
          icon: Icon(Icons.remove),
          color: Colors.grey,
          onPressed: () {
            _value.text = (int.parse(_value.text) - 1).toString();
          },
        ),
      ]),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Error!"),
    content: Text("Quantities specified are greater! Please check once again."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
