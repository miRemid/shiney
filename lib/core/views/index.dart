import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shiney/core/client/model.dart';
import 'package:shiney/core/style/size_config.dart';
import 'package:shiney/core/style/font.dart' as font;
import 'package:shiney/core/global/global.dart' as global;
import 'package:shiney/core/views/manga.dart';
import 'package:shiney/core/views/detail.dart' as detail;

class IndexView extends StatefulWidget {
  IndexView({Key key}) : super(key: key);

  @override
  _IndexView createState() => _IndexView();
}

class _IndexView extends State<IndexView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: HomeContent(),
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search_rounded),
            onPressed: () => {print("Click Personal Btn")},
            iconSize: SizeConfig.defaultSize * 2,
            color: Colors.black,
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined),
            onPressed: () => {print("Click Personal Btn")},
            iconSize: SizeConfig.defaultSize * 2,
            color: font.kTextColor,
          )
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  Widget _buildItem(String title, List<MangItem> items) {
    return Container(
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: font.titleStyle,
          ),
          Container(
            height: 10,
          ),
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              return Card(
                child: Text(items[index].title),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, List<MangItem>>> _getIndexData() async {
    Map<String, List<MangItem>> res = await global.client.getIndexData();
    return res;
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        return _createRowView(context, snapshot);
      default:
        return null;
    }
  }

  Widget _createRowView(BuildContext context, AsyncSnapshot snapshot) {
    var data = snapshot.data;
    Map<String, List<MangItem>> mapData = (data as Map<String, List<MangItem>>);
    print(mapData['rank']);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Rank
            MangaIndexItem(title: '排行榜', items: mapData['rank']),
            // 2. Editor
            MangaIndexItem(title: '编辑推荐', items: mapData['editor']),
            // 3. Fast
            MangaIndexItem(title: '上升最快', items: mapData['fast']),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._getIndexData(),
      builder: this._buildFuture,
    );
  }
}

class MangaIndexItem extends StatelessWidget {

  final String title;
  final List<MangItem> items;

  const MangaIndexItem({
    Key key,
    @required this.title,
    @required this.items,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Text(
            this.title, style: font.titleStyle,textAlign: TextAlign.left ,),
        ),
        // ...List.generate(
        //   items.length, (index) => MangaCard(item: items[index])
        // )
        Container(
          height: 220,
          margin: EdgeInsets.all(5),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              return MangaCard(item: items[index]);
            },
          ),
        )
      ],
    );

  }
}

class MangaCard extends StatelessWidget {
  final MangItem item;

  const MangaCard({
    Key key,
    @required this.item,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => detail.DetailView(href: item.href,)));
      },
      child: SizedBox(
        width: getProportionateScreenWidth(150),

        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                child: Image.network(item.cover),
              )
            ),
            SizedBox(height: 5,),
            Text(item.title)
          ],
        ),
      ),
    );
  }
}
