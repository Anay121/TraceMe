import 'dart:convert';
// import 'dart:html';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
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
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 120),
          child: Container(
            child: Column(
              children: [
                Text(
                  'PRODUCT $args',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15),
                ),
                FutureBuilder(
                    future: getTrace(), //of userid 1
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map data = json.decode(snapshot.data.body);
                        print("HEREE");
                        print(data["t"][args]);
                        print(data["t"][args]["parents"]);
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
  print("here");
  print(prodDict[id]["parents"]);
  return TreeNode(
    title: Card(
        child: Row(children: <Widget>[
      GestureDetector(
        onTap: () => {
          // print(prodDict[args]['name']),
        },
        child: Text("Product $id",
            style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
                fontSize: MediaQuery.of(context).size.width / 15)),
      )
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
