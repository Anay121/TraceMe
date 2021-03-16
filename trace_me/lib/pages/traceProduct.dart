import 'dart:convert';
// import 'dart:html';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree/flutter_tree.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

var args;

class TraceProductPage extends StatefulWidget {
  TraceProductPage(int arg) {
    args = arg;
    args = args.toString();
    print(args);
  }

  @override
  _TraceProductState createState() => _TraceProductState();
}

class _TraceProductState extends State<TraceProductPage> {
  final pnameController = TextEditingController();
  final quantController = TextEditingController();
  final key1Controller = TextEditingController();
  final value1Controller = TextEditingController();
  bool _validateError = false;

  Future<dynamic> getTrace() async {
    String val = await Session().getter('userid');
    return http.post(Helper.url + '/trace',
        body: json.encode({"product_id": args, "user_id": val}));
  }

  Future<dynamic> getErrors() async {
    return http.get(Helper.url + '/getErrors/' + args);
  }

  @override
  void initState() {
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
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 120),
          child: Container(
            child: Column(
              children: [
                Text(
                  'PRODUCT $args',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 12,
                      fontWeight: FontWeight.bold),
                ),
                FutureBuilder(
                    future: getErrors(), //of userid 1
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = json.decode(snapshot.data.body);
                        if (data != []) {
                          return Column(children: [
                            for (var i in data["errors"])
                              Text(
                                'Error: $i',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25,
                                    color: Colors.red),
                              )
                          ]);
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
                FutureBuilder(
                    future: getTrace(), //of userid 1
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map data = json.decode(snapshot.data.body);
                        print("HEREE");
                        print(data["t"][args]);
                        var treeNode = addNodes(context, data["t"],
                            data["t"][args]["parents"], args);
                        return treeNode;
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

addNodes(context, prodDict, parents, id) {
  TextStyle defaultStyle = TextStyle(
      color: Colors.grey, fontSize: MediaQuery.of(context).size.width / 25);
  // print("here ");
  // print(prodDict[id]["trace"]);
  // if (prodDict[id]["trace"].length != 0)
  //   for (var i in prodDict[id]["trace"])
  //     print("${i[0][1]} - ${i[0][2]} TO ${i[1][1]} - ${i[1][2]}");
  return TreeNode(
    title: Card(
        child: Row(children: <Widget>[
      Column(children: [
        GestureDetector(
            onTap: () => {
                  print("Call product details for $id"),
                  Navigator.pushNamed(context, 'ProdTransDetailsPage',
                      arguments: [
                        int.parse(id),
                        prodDict[id]["name"],
                        [
                          prodDict[id]["maker"][0],
                          "${prodDict[id]["maker"][1]} - ${prodDict[id]["maker"][2]}"
                        ],
                        [
                          prodDict[id]["owner"][0],
                          "${prodDict[id]["owner"][1]} - ${prodDict[id]["owner"][2]}"
                        ]
                      ]),
                },
            child: Column(children: [
              Text("ID $id : ${prodDict[id]["name"]}",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                      fontSize: MediaQuery.of(context).size.width / 20)),
            ])),
        // Text("Maker: ${prodDict[id]["maker"][1]} - ${prodDict[id]["maker"][2]}",
        //     style: defaultStyle),
        // Text("Owner: ${prodDict[id]["owner"][1]} - ${prodDict[id]["owner"][2]}",
        //     style: defaultStyle),
        // Text("Transactions:-"),
        Column(children: [
          if (prodDict[id]["trace"].length != 0)
            for (var i in prodDict[id]["trace"])
              Column(children: [
                SizedBox(height: MediaQuery.of(context).size.height / 75),
                RichText(
                    text: TextSpan(style: defaultStyle, children: <TextSpan>[
                  TextSpan(text: "FROM "),
                  TextSpan(
                      text: "${i[0][1]}",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Go to sender page ${i[0][0]}');
                          Navigator.pushNamed(context, 'UserInfoPage',
                              arguments: i[0][0]);
                        }),
                  TextSpan(text: " - ${i[0][2]}")
                ])),
                SizedBox(height: MediaQuery.of(context).size.height / 200),
                RichText(
                    text: TextSpan(style: defaultStyle, children: <TextSpan>[
                  TextSpan(text: "TO "),
                  TextSpan(
                      text: "${i[1][1]}",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Go to receiver page ${i[1][0]}');
                          Navigator.pushNamed(context, 'UserInfoPage',
                              arguments: i[1][0]);
                        }),
                  TextSpan(text: " - ${i[1][2]}")
                ])),
                SizedBox(height: MediaQuery.of(context).size.height / 75),
              ])
        ])
      ]),
    ])),
    expaned: true,
    children: <Widget>[
      if (parents[0] != "-1")
        for (var i in parents)
          addNodes(context, prodDict, prodDict[i]["parents"], i)
      // TreeNode(
      //   title: Text('This is a title!'),
      //   children: <Widget>[
      //       TreeNode(title: Text('This is a title!')),
      //   ],
      // ),
    ],
  );
}
