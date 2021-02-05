import 'package:flutter/material.dart';
import 'package:trace_me/pages/displayProducts.dart';
import 'package:trace_me/pages/login.dart';
import 'package:trace_me/pages/mainHomePage.dart';
import 'package:trace_me/pages/addNewProduct.dart';
import 'package:trace_me/pages/receiverPage.dart';
import 'package:trace_me/pages/splitProduct.dart';
import 'package:trace_me/pages/registerPage.dart';
import 'package:trace_me/pages/productDetailsPage.dart';
import 'package:trace_me/pages/qrScanPage.dart';
import 'package:trace_me/pages/traceProduct.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print(settings.arguments);
  print(settings.name);
  final arguments = settings.arguments;
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => MainHomePage());
    case "LoginPage":
      return MaterialPageRoute(builder: (context) => LoginPage());
    case "DisplayProductsPage":
      return MaterialPageRoute(builder: (context) => DisplayProductsPage());
    case "AddNewProductPage":
      return MaterialPageRoute(
          builder: (context) => AddNewProductPage(arguments));
    case "SplitProductPage":
      return MaterialPageRoute(
          builder: (context) => SplitProductPage(arguments));
    case 'RegisterPage':
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case 'ProductPage':
      return MaterialPageRoute(
          builder: (context) => ProductDetailsPage(arguments));
    case 'QRScanPage':
      return MaterialPageRoute(builder: (context) => QrScanPage());
    case 'ReceiverStatusPage':
      return MaterialPageRoute(builder: (context) => ReceiverPage(arguments));
    case 'TraceProductPage':
      return MaterialPageRoute(
          builder: (context) => TraceProductPage(arguments));
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
