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
  var productList = List<Widget>();
  var productsSelected = List<int>();
  var parentsOfProductsSelected = Map();
  Map productsSelectedQuantities = Map();
  Map parentsToChildren = Map();
  var splitArgs = List<int>();
  bool checked = false;

  Future<dynamic> getProducts() async {
    String val = await Session().getter('userid');
    return http.get(Helper.url + '/get_products/' + val);
  }

  Future<dynamic> mergeProducts(List childrenIds) async {
    String val = await Session().getter('userid');
    return http.post(Helper.url + '/merge',
        body: json.encode({"childrenIds": childrenIds, "ownerId": val}));
  }

  @override
  void initState() {
    super.initState();
  }

  addInProductList(BuildContext context, int id, String name, String quant,
      String parentsArray) {
    productList.add(Card(
      child: Row(
        children: <Widget>[
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Checkbox(
                value: checked,
                activeColor: Colors.green,
                onChanged: (bool newValue) {
                  setState(() {
                    checked = newValue;
                    if (checked) {
                      productsSelected.add(id);
                      productsSelectedQuantities[id] = int.parse(quant);
                      if (parentsOfProductsSelected
                          .containsKey(json.encode(parentsArray))) {
                        parentsOfProductsSelected[json.encode(parentsArray)] +=
                            1;
                      } else {
                        parentsOfProductsSelected[json.encode(parentsArray)] =
                            1;
                      }
                    } else {
                      productsSelected.remove(id);
                      productsSelectedQuantities.remove(quant);
                      if (parentsOfProductsSelected[
                              json.encode(parentsArray)] ==
                          1) {
                        parentsOfProductsSelected
                            .remove(json.encode(parentsArray));
                      } else {
                        parentsOfProductsSelected[json.encode(parentsArray)] -=
                            1;
                      }
                    }
                    print(productsSelected);
                    print(productsSelectedQuantities);
                    print(parentsOfProductsSelected);
                  });
                });
          }),
          GestureDetector(
            onTap: () async {
              print("tapping");
              String owner = await Session().getter('userid');
              Navigator.pushNamed(
                context,
                "ProductPage",
                arguments: json.encode({
                  'product_id': id.toString(),
                  'product_name': name,
                  'qty': quant,
                  'owner': owner,
                }),
              );
            },
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 5,
                  color: Color(0xFFE98D39),
                ),
                Container(
                  child: Column(children: [
                    Container(
                        // width: MediaQuery.of(context).size.width * 0.6,
                        margin: EdgeInsets.all(10),
                        child: Text(name)),
                    Container(
                        // width: MediaQuery.of(context).size.width * 0.6,
                        margin: EdgeInsets.all(10),
                        child: Text("QTY - $quant"))
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
          child: Container(
            height: MediaQuery.of(context).size.height - 180,
            width: 400,
            child: Column(
              children: [
                Text(
                  'Your Products',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
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
                        style: myOrangeButtonStyle,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 20),
                    Expanded(
                      child: (TextButton(
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
                          'Split a Product',
                        ),
                        style: myOrangeButtonStyle,
                      )),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 20),
                    Expanded(
                      child: (TextButton(
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
                        style: myOrangeButtonStyle,
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
                              addInProductList(context, i[0], i[2],
                                  i[1].toString(), parentsArray);
                            }
                          } else {
                            var pos = 0;
                            for (var i in val) {
                              if (pos == 0) {
                                productList.add(Container(
                                  height: 3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xFFE98D39),
                                ));
                                addInProductList(context, i[0], i[2],
                                    i[1].toString(), parentsArray);
                              } else if (pos == val.length - 1) {
                                addInProductList(context, i[0], i[2],
                                    i[1].toString(), parentsArray);
                                productList.add(Container(
                                  height: 3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xFFE98D39),
                                ));
                              } else {
                                addInProductList(context, i[0], i[2],
                                    i[1].toString(), parentsArray);
                              }
                              pos = pos + 1;
                            }
                          }
                        }
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
