import 'package:flutter/material.dart';
import 'package:shiney/core/views/detail.dart' as detail;
import 'package:shiney/core/views/index.dart' as index;
import 'package:shiney/core/views/manga.dart' as manga;

const String IndexRouter = "index";
const String DetailRouter = "detail";
const String SearchRouter = "search";
const String MangaRouter = "manga";
const String Profile = "profile";
const String Setting = "setting";

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case IndexRouter:
      return MaterialPageRoute(builder: (context) => index.IndexView());
    case DetailRouter:
      String href = settings.arguments as String;
      return MaterialPageRoute(builder: (context) => detail.DetailView(href: href,));
    case MangaRouter:
      List<String> args = settings.arguments as List<String>;
      return MaterialPageRoute(builder: (context) => manga.MangaView(url: args[0], next: args[1],prev: args[2],));
    default:
      return MaterialPageRoute(builder: (context) => index.IndexView());
  }
}