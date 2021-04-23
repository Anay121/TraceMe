import 'package:flutter/material.dart';
import 'package:trace_me/pages/customerViewPage.dart';
import 'package:trace_me/pages/displayProducts.dart';
import 'package:trace_me/pages/login.dart';
import 'package:trace_me/pages/mainHomePage.dart';
import 'package:trace_me/pages/addNewProduct.dart';
import 'package:trace_me/pages/prodTransDetailsPage.dart';
import 'package:trace_me/pages/ranking.dart';
import 'package:trace_me/pages/receiverPage.dart';
import 'package:trace_me/pages/receiverStatus.dart';
import 'package:trace_me/pages/splitProduct.dart';
import 'package:trace_me/pages/registerPage.dart';
import 'package:trace_me/pages/productDetailsPage.dart';
import 'package:trace_me/pages/qrScanPage.dart';
import 'package:trace_me/pages/statusSender.dart';
import 'package:trace_me/pages/traceProduct.dart';
import 'package:trace_me/pages/userInfoPage.dart';

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
    case 'ReceiverPage':
      return MaterialPageRoute(builder: (context) => ReceiverPage(arguments));
    case 'StatusSenderPage':
      return MaterialPageRoute(builder: (context) => StatusSender(arguments));
    case 'StatusReceiverPage':
      return MaterialPageRoute(builder: (context) => StatusReceiver(arguments));
    case 'TraceProductPage':
      return MaterialPageRoute(
          builder: (context) => TraceProductPage(arguments));
    case 'UserInfoPage':
      return MaterialPageRoute(builder: (context) => UserInfoPage(arguments));
    case "ProdTransDetailsPage":
      return MaterialPageRoute(
          builder: (context) => ProdTransDetailsPage(arguments));
    case "CustomerViewPage":
      return MaterialPageRoute(builder: (context) => CustomerViewPage());
    case "RankingPage":
      return MaterialPageRoute(builder: (context) => RankingPage());
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
