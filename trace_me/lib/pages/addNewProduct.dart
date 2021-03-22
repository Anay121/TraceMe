import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

var args = new List<int>();

class AddNewProductPage extends StatefulWidget {
  AddNewProductPage(List<int> arg) {
    args = arg;
    print(args);
    // fields.add(DataRow(
    //   false,
    //   key: 'location',
    // ));
  }

  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProductPage> {
  final pnameController = TextEditingController();
  final quantController = TextEditingController();
  // final key1Controller = TextEditingController();
  // final value1Controller = TextEditingController();
  List<DataRow> fields = List<DataRow>();
  bool _validateError = false;

  Future<dynamic> addProduct(String productName) async {
    Map object = Map();
    object["quantity"] = quantController.text;
    for (int i = 0; i < fields.length; i++) {
      Map val = fields[i].getData();
      if (val['key'].toLowerCase().contains("harvest") ||
          val['key'].toLowerCase().contains("crush")) {
        object[val['key'].toLowerCase()] = val['value'];
      } else {
        object[val['key']] = val['value'];
      }
    }
    //add type of scm "sugarcane_scm" if SCM starts with sugarcane crop
    if (productName.toLowerCase().contains("sugarcane") && args[0] == -1) {
      object["type"] = "sugarcane_scm";
    }
    print(object);
    String val = await Session().getter('userid');
    return http.post(Helper.url + '/add_product',
        body: json.encode({
          "product_name": productName,
          "product_properties": object,
          "user_id": val,
          "parent_ids": args
        }));
  }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
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
                'ADD PRODUCT',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 15, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                  decoration: InputDecoration(labelText: 'Product Name..'),
                  controller: pnameController),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: TextFormField(
                        decoration: InputDecoration(labelText: 'Quantity..'),
                        controller: quantController),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.grey,
                    onPressed: () {
                      quantController.text = (int.parse(quantController.text) + 1).toString();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    color: Colors.grey,
                    onPressed: () {
                      quantController.text = (int.parse(quantController.text) - 1).toString();
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // DataRow(),
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
                          fields.insert(0, DataRow(true));
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          )),
        ),
        Expanded(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 12,
                child: TextButton(
                  onPressed: () => {
                    // print("here"),
                    // print(pnameController.text),

                    addProduct(pnameController.text).then((val) {
                      // check validation
                      print(val.statusCode);
                      if (val.statusCode == '401') {
                        setState(() {
                          _validateError = true;
                        });
                      }
                      // redirect with params
                      else {
                        Navigator.pop(context);
                        Navigator.popAndPushNamed(context, 'DisplayProductsPage');
                      }
                    }),
                  },
                  child: Text("ADD PRODUCT"),
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
  final _key = TextEditingController();
  final _value = TextEditingController();
  final bool allowNull;

  DataRow(this.allowNull, {String key = ''}) {
    _key.text = key;
  }

  Map<String, String> getData() {
    String key = _key.text;
    String value = _value.text;
    return {'key': key, 'value': value};
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
              decoration: InputDecoration(labelText: 'KEY'),
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
                labelText: 'VALUE',
                suffixText: '*',
                suffixStyle: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
