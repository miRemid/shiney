import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:shiney/core/client/model.dart';

const INDEX_URL = "http://www.mangabz.com/";
const SEARCH_URL = "http://www.mangabz.com/search";

class ShineyHTTPClient {
  Dio _client;

  ShineyHTTPClient() {
    this._client = new Dio();
    this._client.options.headers =  {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate',
      'Host': 'www.mangabz.com',
      'Referer': 'http://www.mangabz.com/m161207/',
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

  Future<String> getChapter() async {
    Response response = await this._client.get('http://www.mangabz.com/m161207-p2/chapterimage.ashx?cid=161207&page=2&key=&_cid=161207&_mid=713&_dt=2021-02-08+08%3A33%3A09&_sign=269dbf9a7e76249514f7459fe1e5b4de');
    print(response.data);
    return response.data;
  }

}

main(List<String> args) {
  ShineyHTTPClient client = new ShineyHTTPClient();
  client.getChapter().then((value) => {
    print(value),
  });
}
