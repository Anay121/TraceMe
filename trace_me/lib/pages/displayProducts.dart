import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

class DisplayProductsPage extends StatefulWidget {
  @override
  _DisplayProductsState createState() => _DisplayProductsState();
}

class _DisplayProductsState extends State<DisplayProductsPage> {
  Future<dynamic> getProducts() async {
    Future<dynamic> value;
    // Session().getter('userid').then((val) {
    //   return http.get(Helper.url + '/get_products/' + val);
    // });
    String val = await Session().getter('userid');
    return http.get(Helper.url + '/get_products/' + val);
    // print(value);
    // return value;
  }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
    var productList = List<Widget>();
    var productsSelected = List<String>();
    bool checked = false;

    return Scaffold(
      body: Column(children: [
        ClipPath(
          // clipper: BezierClipper(),
          child: Container(
            color: Color.fromRGBO(255, 91, 53, 1),
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
                Text(
                  'Your Products',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: RaisedButton(
                        onPressed: () => {
                          Navigator.pushNamed(context, 'AddNewProductPage',
                              arguments: productsSelected)
                        },
                        child: Text(
                          'Add new Product',
                        ),
                        color: Color(0xFFCB672F),
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 20),
                    Expanded(
                      child: (RaisedButton(
                        onPressed: () => {
                          Navigator.pushNamed(context, 'SplitProductPage',
                              arguments: productsSelected)
                        },
                        child: Text(
                          'Split Product',
                        ),
                        color: Color(0xFFCB672F),
                        textColor: Colors.white,
                      )),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 20),
                    Expanded(
                      child: (RaisedButton(
                        onPressed: () => {
                          // Navigator.pushNamed(context, 'SplitProductPage')
                        },
                        child: Text(
                          'Merge the split',
                        ),
                        color: Color(0xFFCB672F),
                        textColor: Colors.white,
                      )),
                    ),
                  ],
                ),
                FutureBuilder(
                    future: getProducts(), //of userid 1
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map data = json.decode(snapshot.data.body);
                        // print(data["product_dict"]);
                        // print("here");

                        for (var k in data["product_dict"].keys) {
                          // print(productsSelected);
                          // "Key : $k, value : ${json.decode(data["product_dict"][k]["encoded_properties"])["quantity"]}");
                          // productList.add(Text("Key: $k, Name: ${data["product_dict"][k]["name"]}"));
                          productList.add(Card(
                            child: Row(
                              children: <Widget>[
                                StatefulBuilder(builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Checkbox(
                                      value: checked,
                                      activeColor: Colors.green,
                                      onChanged: (bool newValue) {
                                        setState(() {
                                          checked = newValue;
                                          if (checked) {
                                            productsSelected.add(k);
                                          } else {
                                            productsSelected.remove(k);
                                          }
                                          print(productsSelected);
                                        });
                                      });
                                }),
                                Container(
                                  height: 50,
                                  width: 5,
                                  color: Color(0xFFE98D39),
                                ),
                                GestureDetector(
                                    onTap: () => {
                                          // Navigator.pushNamed(
                                          //     context, "DisplayProductPage")
                                        },
                                    child: ((Column(children: [
                                      Container(
                                          margin: EdgeInsets.all(10),
                                          child: Text(
                                              data["product_dict"][k]["name"])),
                                      Container(
                                          margin: EdgeInsets.all(10),
                                          child: Text(
                                              "QTY - ${json.decode(data["product_dict"][k]["encoded_properties"])["quantity"]}"))
                                    ]))))
                              ],
                            ),
                          ));
                        }
                        // Build the widget with data.
                        // return Center(
                        //     child: Container(
                        //         child: Text('Data: ${snapshot.data.body}')));
                        return Flexible(
                            child: ListView.builder(
                          itemCount: productList.length,
                          // scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            print(productList[index]);
                            return new ListTile(
                              title: productList[index],
                            );
                          },
                        ));
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double _xScaling = size.width / 550;
    final double _yScaling = size.height / 250;
    path.lineTo(478.296 * _xScaling, 161.15699999999998 * _yScaling);
    path.cubicTo(
      407.956 * _xScaling,
      149.3021 * _yScaling,
      302.774 * _xScaling,
      107.2207 * _yScaling,
      214 * _xScaling,
      131 * _yScaling,
    );
    path.cubicTo(
      67 * _xScaling,
      170.376 * _yScaling,
      16.203999999999994 * _xScaling,
      86.2874 * _yScaling,
      16.203999999999994 * _xScaling,
      41 * _yScaling,
    );
    path.cubicTo(
      16.203999999999994 * _xScaling,
      -38.5 * _yScaling,
      325.21000000000004 * _xScaling,
      -56.843 * _yScaling,
      460.796 * _xScaling,
      -56.843 * _yScaling,
    );
    path.cubicTo(
      596.3820000000001 * _xScaling,
      -56.843 * _yScaling,
      554.5 * _xScaling,
      174 * _yScaling,
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
    );
    path.cubicTo(
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
