import 'package:flutter/material.dart';
import 'package:shiney/core/views/detail.dart' as detail;
import 'package:shiney/core/views/index.dart' as index;

const String IndexRouter = "index";
const String DetailRouter = "detail";
const String SearchRouter = "search";
const String Profile = "profile";
const String Setting = "setting";

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "index":
      return MaterialPageRoute(builder: (context) => index.IndexView());
    case "detail":
      String href = settings.arguments as String;
      return MaterialPageRoute(builder: (context) => detail.DetailView(href: href,));
    default:
      return MaterialPageRoute(builder: (context) => index.IndexView());
  }
}