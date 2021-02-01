import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

String alertBoxMsg = "";

class DisplayProductsPage extends StatefulWidget {
  @override
  _DisplayProductsState createState() => _DisplayProductsState();
}

class _DisplayProductsState extends State<DisplayProductsPage> {
  Future<dynamic> getProducts() async {
    // Session().getter('userid').then((val) {
    //   return http.get(Helper.url + '/get_products/' + val);
    // });
    String val = await Session().getter('userid');
    return http.get(Helper.url + '/get_products/' + val);
    // print(value);
    // return value;
  }

  Future<dynamic> mergeProducts(List childrenIds) async {
    // Session().getter('userid').then((val) {
    //   return http.get(Helper.url + '/get_products/' + val);
    // });
    String val = await Session().getter('userid');
    return http.post(Helper.url + '/merge',
        body: json.encode({"childrenIds": childrenIds, "ownerId": val}));
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
    var productsSelected = List<int>();
    var parentsOfProductsSelected = Map();
    Map productsSelectedQuantities = Map();
    Map parentsToChildren = Map();
    var splitArgs = List<int>();
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
                          if (productsSelected.isEmpty)
                            {
                              Navigator.pushNamed(context, 'AddNewProductPage',
                                  arguments: [-1])
                            }
                          else
                            {
                              Navigator.pushNamed(context, 'AddNewProductPage',
                                  arguments: productsSelected)
                            }
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
                          if (productsSelected.length == 1)
                            {
                              splitArgs = [
                                productsSelected[0],
                                productsSelectedQuantities[productsSelected[0]]
                              ],
                              Navigator.pushNamed(context, 'SplitProductPage',
                                  arguments: splitArgs)
                            }
                          else
                            {
                              if (productsSelected.isEmpty)
                                {
                                  alertBoxMsg =
                                      "Please select the product you want to split."
                                }
                              else
                                {
                                  alertBoxMsg =
                                      "Please select only one product."
                                },
                              showAlertDialog(context)
                            }
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
                          if (parentsOfProductsSelected.length == 1 &&
                              parentsOfProductsSelected.values.elementAt(0) > 1)
                            {
                              mergeProducts(productsSelected).then((val) {
                                // check validation
                                print(val.statusCode);
                                if (val.statusCode == 401) {
                                  // setState(() {
                                  //   _validateError = true;
                                  // });
                                }
                                // redirect with params
                                else {
                                  Navigator.pushNamed(
                                      context, 'DisplayProductsPage');
                                }
                              }),
                            }
                          else
                            {
                              alertBoxMsg =
                                  "Selection should be for children of same parent product!",
                              showAlertDialog(context),
                            }
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
                          int id = int.parse(k);
                          var parentsArray = List<int>.from(
                              data["product_dict"][k]["parent_id_list"]);
                          print(parentsArray);
                          // if (parentsArray[0] != -1) {
                          if (parentsToChildren
                              .containsKey(json.encode(parentsArray))) {
                            parentsToChildren[json.encode(parentsArray)].add([
                              id,
                              json.decode(data["product_dict"][k]
                                  ["encoded_properties"])["quantity"],
                              data["product_dict"][k]["name"]
                            ]);
                          } else {
                            parentsToChildren[json.encode(parentsArray)] = [
                              [
                                id,
                                json.decode(data["product_dict"][k]
                                    ["encoded_properties"])["quantity"],
                                data["product_dict"][k]["name"]
                              ]
                            ];
                          }
                          // }
                        }
                        print("parentstochildren");
                        print(parentsToChildren);

                        for (var k in parentsToChildren.keys) {
                          var parentsArray = k;
                          var val = parentsToChildren[k];
                          if (json.decode(parentsArray)[0] == -1 ||
                              val.length == 1) {
                            for (var i in val) {
                              productList.add(Card(
                                child: Row(
                                  children: <Widget>[
                                    StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Checkbox(
                                          value: checked,
                                          activeColor: Colors.green,
                                          onChanged: (bool newValue) {
                                            setState(() {
                                              checked = newValue;
                                              if (checked) {
                                                productsSelected.add(i[0]);
                                                productsSelectedQuantities[
                                                    i[0]] = int.parse(i[1]);
                                                if (parentsOfProductsSelected
                                                    .containsKey(json.encode(
                                                        parentsArray))) {
                                                  parentsOfProductsSelected[
                                                      json.encode(
                                                          parentsArray)] += 1;
                                                } else {
                                                  parentsOfProductsSelected[
                                                      json.encode(
                                                          parentsArray)] = 1;
                                                }
                                              } else {
                                                productsSelected.remove(i[0]);
                                                productsSelectedQuantities
                                                    .remove(i[1]);
                                                if (parentsOfProductsSelected[
                                                        json.encode(
                                                            parentsArray)] ==
                                                    1) {
                                                  parentsOfProductsSelected
                                                      .remove(json.encode(
                                                          parentsArray));
                                                } else {
                                                  parentsOfProductsSelected[
                                                      json.encode(
                                                          parentsArray)] -= 1;
                                                }
                                              }
                                              print(productsSelected);
                                              print(productsSelectedQuantities);
                                              print(parentsOfProductsSelected);
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
                                              child: Text(i[2])),
                                          Container(
                                              margin: EdgeInsets.all(10),
                                              child: Text("QTY - ${i[1]}"))
                                        ]))))
                                  ],
                                ),
                              ));
                            }
                          } else {
                            var pos = 0;
                            for (var i in val) {
                              if (pos == 0) {
                                productList.add(Column(children: [
                                  Container(
                                    height: 3,
                                    width: MediaQuery.of(context).size.width,
                                    color: Color(0xFFE98D39),
                                  ),
                                  Card(
                                    child: Row(
                                      children: <Widget>[
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Checkbox(
                                              value: checked,
                                              activeColor: Colors.green,
                                              onChanged: (bool newValue) {
                                                setState(() {
                                                  checked = newValue;
                                                  if (checked) {
                                                    productsSelected.add(i[0]);
                                                    productsSelectedQuantities[
                                                        i[0]] = int.parse(i[1]);
                                                    if (parentsOfProductsSelected
                                                        .containsKey(json.encode(
                                                            parentsArray))) {
                                                      parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] += 1;
                                                    } else {
                                                      parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] = 1;
                                                    }
                                                  } else {
                                                    productsSelected
                                                        .remove(i[0]);
                                                    productsSelectedQuantities
                                                        .remove(i[1]);
                                                    if (parentsOfProductsSelected[
                                                            json.encode(
                                                                parentsArray)] ==
                                                        1) {
                                                      parentsOfProductsSelected
                                                          .remove(json.encode(
                                                              parentsArray));
                                                    } else {
                                                      parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] -= 1;
                                                    }
                                                  }
                                                  print(productsSelected);
                                                  print(
                                                      productsSelectedQuantities);
                                                  print(
                                                      parentsOfProductsSelected);
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
                                                  child: Text(i[2])),
                                              Container(
                                                  margin: EdgeInsets.all(10),
                                                  child: Text("QTY - ${i[1]}"))
                                            ]))))
                                      ],
                                    ),
                                  )
                                ]));
                              } else if (pos == val.length - 1) {
                                productList.add(Column(children: [
                                  Card(
                                    child: Row(
                                      children: <Widget>[
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Checkbox(
                                              value: checked,
                                              activeColor: Colors.green,
                                              onChanged: (bool newValue) {
                                                setState(() {
                                                  checked = newValue;
                                                  if (checked) {
                                                    productsSelected.add(i[0]);
                                                    productsSelectedQuantities[
                                                        i[0]] = int.parse(i[1]);
                                                    if (parentsOfProductsSelected
                                                        .containsKey(json.encode(
                                                            parentsArray))) {
                                                      parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] += 1;
                                                    } else {
                                                      parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] = 1;
                                                    }
                                                  } else {
                                                    productsSelected
                                                        .remove(i[0]);
                                                    productsSelectedQuantities
                                                        .remove(i[1]);
                                                    if (parentsOfProductsSelected[
                                                            json.encode(
                                                                parentsArray)] ==
                                                        1) {
                                                      parentsOfProductsSelected
                                                          .remove(json.encode(
                                                              parentsArray));
                                                    } else {
                                                      parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] -= 1;
                                                    }
                                                  }
                                                  print(productsSelected);
                                                  print(
                                                      productsSelectedQuantities);
                                                  print(
                                                      parentsOfProductsSelected);
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
                                                  child: Text(i[2])),
                                              Container(
                                                  margin: EdgeInsets.all(10),
                                                  child: Text("QTY - ${i[1]}"))
                                            ]))))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 3,
                                    width: MediaQuery.of(context).size.width,
                                    color: Color(0xFFE98D39),
                                  ),
                                ]));
                              } else {
                                productList.add(Card(
                                  child: Row(
                                    children: <Widget>[
                                      StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return Checkbox(
                                            value: checked,
                                            activeColor: Colors.green,
                                            onChanged: (bool newValue) {
                                              setState(() {
                                                checked = newValue;
                                                if (checked) {
                                                  productsSelected.add(i[0]);
                                                  productsSelectedQuantities[
                                                      i[0]] = int.parse(i[1]);
                                                  if (parentsOfProductsSelected
                                                      .containsKey(json.encode(
                                                          parentsArray))) {
                                                    parentsOfProductsSelected[
                                                        json.encode(
                                                            parentsArray)] += 1;
                                                  } else {
                                                    parentsOfProductsSelected[
                                                        json.encode(
                                                            parentsArray)] = 1;
                                                  }
                                                } else {
                                                  productsSelected.remove(i[0]);
                                                  productsSelectedQuantities
                                                      .remove(i[1]);
                                                  if (parentsOfProductsSelected[
                                                          json.encode(
                                                              parentsArray)] ==
                                                      1) {
                                                    parentsOfProductsSelected
                                                        .remove(json.encode(
                                                            parentsArray));
                                                  } else {
                                                    parentsOfProductsSelected[
                                                        json.encode(
                                                            parentsArray)] -= 1;
                                                  }
                                                }
                                                print(productsSelected);
                                                print(
                                                    productsSelectedQuantities);
                                                print(
                                                    parentsOfProductsSelected);
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
                                                child: Text(i[2])),
                                            Container(
                                                margin: EdgeInsets.all(10),
                                                child: Text("QTY - ${i[1]}"))
                                          ]))))
                                    ],
                                  ),
                                ));
                              }
                              pos = pos + 1;
                            }
                          }
                        }

                        // for (var k in data["product_dict"].keys) {
                        //   // print(data["product_dict"][k]["parent_id_list"]);
                        //   // "Key : $k, value : ${json.decode(data["product_dict"][k]["encoded_properties"])["quantity"]}");
                        //   // productList.add(Text("Key: $k, Name: ${data["product_dict"][k]["name"]}"));
                        //   int id = int.parse(k);
                        //   var parentsArray = List<int>.from(
                        //       data["product_dict"][k]["parent_id_list"]);
                        //   // .Cast<int>()
                        //   // .ToList();
                        //   productList.add(Card(
                        //     child: Row(
                        //       children: <Widget>[
                        //         StatefulBuilder(builder: (BuildContext context,
                        //             StateSetter setState) {
                        //           return Checkbox(
                        //               value: checked,
                        //               activeColor: Colors.green,
                        //               onChanged: (bool newValue) {
                        //                 setState(() {
                        //                   checked = newValue;
                        //                   if (checked) {
                        //                     productsSelected.add(id);
                        //                     productsSelectedQuantities[id] =
                        //                         int.parse(json.decode(data[
                        //                                     "product_dict"][k]
                        //                                 ["encoded_properties"])[
                        //                             "quantity"]);
                        //                     if (parentsOfProductsSelected
                        //                         .containsKey(json
                        //                             .encode(parentsArray))) {
                        //                       parentsOfProductsSelected[json
                        //                           .encode(parentsArray)] += 1;
                        //                     } else {
                        //                       parentsOfProductsSelected[json
                        //                           .encode(parentsArray)] = 1;
                        //                     }
                        //                   } else {
                        //                     productsSelected.remove(id);
                        //                     productsSelectedQuantities
                        //                         .remove(id);
                        //                     if (parentsOfProductsSelected[json
                        //                             .encode(parentsArray)] ==
                        //                         1) {
                        //                       parentsOfProductsSelected.remove(
                        //                           json.encode(parentsArray));
                        //                     } else {
                        //                       parentsOfProductsSelected[json
                        //                           .encode(parentsArray)] -= 1;
                        //                     }
                        //                   }
                        //                   print(productsSelected);
                        //                   print(productsSelectedQuantities);
                        //                   print(parentsOfProductsSelected);
                        //                 });
                        //               });
                        //         }),
                        //         Container(
                        //           height: 50,
                        //           width: 5,
                        //           color: Color(0xFFE98D39),
                        //         ),
                        //         GestureDetector(
                        //             onTap: () => {
                        //                   // Navigator.pushNamed(
                        //                   //     context, "DisplayProductPage")
                        //                 },
                        //             child: ((Column(children: [
                        //               Container(
                        //                   margin: EdgeInsets.all(10),
                        //                   child: Text(
                        //                       data["product_dict"][k]["name"])),
                        //               Container(
                        //                   margin: EdgeInsets.all(10),
                        //                   child: Text(
                        //                       "QTY - ${json.decode(data["product_dict"][k]["encoded_properties"])["quantity"]}"))
                        //             ]))))
                        //       ],
                        //     ),
                        //   ));
                        // }
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

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Error!"),
    content: Text(alertBoxMsg),
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
