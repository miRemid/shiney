import 'package:flutter/material.dart';
import 'package:shiney/core/style/font.dart' as font;

class DetailView extends StatefulWidget {

  final String href;

  DetailView({
    Key key,
    @required this.href,
  }) : super(key: key);

  @override
  _DetailView createState() => _DetailView(href: href);
}

class _DetailView extends State<DetailView> {

  final String href;

  _DetailView({
    @required this.href,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: DetailContent(href: href),
    );
  }
}

class DetailContent extends StatelessWidget {

  final String href;

  DetailContent({
    Key key,
    @required this.href,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text(href, style: font.titleStyle,),
    );
  }
}