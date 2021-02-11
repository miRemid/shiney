import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:shiney/core/client/model.dart';

const INDEX_URL = "http://www.mangabz.com";
const SEARCH_URL = "http://www.mangabz.com/search";
const FUN_URL2 = "http://api.zxykm.ltd/getImages";

class ShineyHTTPClient {
  Dio _client;

  final _totalRegexp = new RegExp(r"[^0-9]");

  ShineyHTTPClient() {
    this._client = new Dio();
    this._client.options.headers =  {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate',
    };
  }

  MangItem _parseItem(Element item, String prefix) {
    String cover = item.getElementsByTagName('img')[0].attributes['src'];
    Element bind = item.getElementsByClassName(prefix + '-title')[0];
    Element a = bind.getElementsByTagName('a')[0];
    String title = a.innerHtml;
    String href = a.attributes['href'];
    List<Element> tag = item.getElementsByTagName('span');
    List<String> tags = new List<String>();
    for (Element t in tag) {
      tags.add(t.text);
    }
    return new MangItem(cover, href, title, tags);
  }

  Future<Map<String, List<MangItem>>> getIndexData() async {
    Map<String, List<MangItem>> res = new Map<String, List<MangItem>>();

    Response response = await this._client.get(INDEX_URL);
    Document document = parse(response.data);

    res['rank'] = this._getRankList(document.getElementsByClassName('rank-list')[0]);
    res['fast'] = this._getFastList(document.getElementsByClassName('carousel-right-list')[0]);

    // index-list
    List<Element> indexItemsList = document.getElementsByClassName('index-manga-list');
    res['popular'] = this._extracIndexMangaList(indexItemsList[0]);
    res['editor'] = this._extracIndexMangaList(indexItemsList[1]);
    res['boom'] = this._extracIndexMangaList(indexItemsList[2]);
    res['love'] = this._extracIndexMangaList(indexItemsList[3]);
    res['school'] = this._extracIndexMangaList(indexItemsList[4]);
    res['fantasy'] = this._extracIndexMangaList(indexItemsList[5]);
    res['science'] = this._extracIndexMangaList(indexItemsList[6]);

    return res;
  }

  List<MangItem> _getRankList(Element rankList) {
    List<MangItem> res = new List<MangItem>();
    List<Element> rankItmes = rankList.getElementsByClassName('list');
    for (Element item in rankItmes) {
      res.add(this._parseItem(item, 'rank-item'));
    }
    return res;
  }

  List<MangItem> _extracIndexMangaList(Element itemList) {
    List<MangItem> res = new List<MangItem>();
    List<Element> mangItems =
    itemList.getElementsByClassName('index-manga-item');
    for (Element item in mangItems) {
      res.add(this._parseItem(item, 'index-manga-item'));
    }
    return res;
  }

  List<MangItem> _getFastList(Element fastList) {
    String cls = 'carousel-right-item';
    List<MangItem> res = new List<MangItem>();
    List<Element> fastItems = fastList.getElementsByClassName(cls);
    for (Element item in fastItems) {
      MangItem ii = this._parseItem(item, cls);
      ii.content = item.getElementsByClassName(cls+'-content')[0].text;
      ii.author = item.getElementsByClassName(cls+'-subtitle')[0].text;
      res.add(ii);
    }
    return res;
  }

  Future<ImgResponse> getChapterImages(String href) async {
    Map<String, dynamic> map = Map();
    map["url"] = INDEX_URL + href;
    Response response = await this._client.get(FUN_URL2, queryParameters: map);
    ImgResponse imgResponse = ImgResponse.fromMap(response.data);
    return imgResponse;
  }
  
  Future<ImgResponse> testResponse(String url) async {

    List<String> data = [
      "http://image.mangabz.com/1/134/160658/1_5568.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/2_1165.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/3_1630.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/4_1399.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/5_5557.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/6_6752.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/7_9261.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/8_6425.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/9_8322.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/10_5523.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk=",
      "http://image.mangabz.com/1/134/160658/11_7717.jpg?cid=160658&key=7de7d47fe97e85373e3e8a5c65271e83&uk="
    ];
    return ImgResponse(code: 0, data: data, messgae: "null");
  }

  Future<MangDetail> getMangaDetailInfo(String href) async {
    MangDetail detail = new MangDetail();
    MangDetailInfo info = new MangDetailInfo();
    String url = INDEX_URL + href;
    Response response = await this._client.get(url);
    Document document = parse(response.data);

    // get info
    Element detailInfo1 = document.getElementsByClassName("detail-info-1")[0];
    info.cover = detailInfo1.getElementsByTagName("img")[0].attributes["src"];
    info.title = detailInfo1.getElementsByClassName("detail-info-title")[0].text.trim();
    info.stars = detailInfo1.getElementsByClassName("detail-info-stars")[0].getElementsByTagName("span")[0].text.trim();
    Element tips = detailInfo1.getElementsByClassName("detail-info-tip")[0];
    List<Element> spans = tips.getElementsByTagName("span");
    String authorString = spans[0].getElementsByTagName("a")[0].text.trim();
    info.authors = authorString.split(" ");
    List<Element> tagItems = tips.getElementsByClassName("item");
    info.tags = new List();
    tagItems.forEach((item) => {
      info.tags.add(item.text.trim())
    });

    Element detailInfo2 = document.getElementsByClassName("detail-info-2")[0];
    info.content = detailInfo2.getElementsByClassName("detail-info-content")[0].text.trim();
    detail.info = info;

    // get list state
    Element listFormTitle = document.getElementsByClassName("detail-list-form-title")[0];
    Element latest = listFormTitle.getElementsByClassName('s')[0].getElementsByTagName('a')[0];
    detail.latestHref = latest.attributes['href'];

    // get list items
    Element listFormCon = document.getElementsByClassName("detail-list-form-con")[0];
    List<Element> items = listFormCon.getElementsByClassName("detail-list-form-item");
    detail.items = new List<MangDetailItem>();
    items.forEach((element) {
      MangDetailItem item = new MangDetailItem();
      item.href = element.attributes['href'];
      item.text = element.text.replaceAll(' ', '');
      detail.items.add(item);
    });

    return detail;
  }

  Future<MangSearch> getMangaSearch(String item, int page) async {
    MangSearch search = new MangSearch();
    String url = SEARCH_URL + "?title=" + item + "&page=" + page.toString();
    Response response = await this._client.get(url);
    Document document = parse(response.data);

    // 1. get total
    Element totalElement = document.getElementsByClassName("result-title")[0];
    String t = totalElement.text.replaceAll(this._totalRegexp, '');
    search.total = int.parse(t);

    // 2. get items
    List<Element> mhitems = document.getElementsByClassName('mh-list')[0].getElementsByClassName('mh-item');
    search.items = new List<MangSearchItem>();
    mhitems.forEach((element) {
      MangSearchItem item = new MangSearchItem();
      // 1. get title
      Element title = element.getElementsByClassName('title')[0].getElementsByTagName('a')[0];
      item.title = title.text;
      item.href = title.attributes['href'];

      // 2. get cover
      item.cover = element.getElementsByTagName('img')[0].attributes['src'];

      // 3. get latest chapter
      item.chapter = element.getElementsByClassName('chapter')[0].text.replaceAll(' ', '');

      search.items.add(item);
    });

    return search;
  }
}

main(List<String> args) {
  ShineyHTTPClient client = new ShineyHTTPClient();
  client.getMangaSearch("尾田荣一郎", 1).then((value) => {
    print(value.total),
    print(value.items.length),
    value.items.forEach((element) {
      print(element.title);
      print(element.chapter);
      print(element.href);
      print(element.cover);
    })
  });

}
