import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// main() 메서드는 화살표(=>) 표기법을 사용합니다. 한 줄 함수 또는 메서드에 화살표 표기법을 사용하세요.
void main() => runApp(MyApp());

/// 앱은 StatelessWidget을 상속받아 앱 자체를 위젯으로 만듭니다.
/// Flutter에서는 정렬, 여백, 레이아웃 등 거의 모든것이 위젯입니다.
/// Stateless 위젯은 변경불가능합니다. 속성을 변경할 수 없습니다(모든 값이 final입니다.)
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData( // Add the 3 lines from here...
        primaryColor: Colors.white,
      ),
      home: MyHomePage(),
      // appBar: AppBar(
      //   title: Text('Welcome 2 Flutter'),
      // ),
      // body: Center(
      // child: Text('Hello World'),
      // child: Text(wordPair.asPascalCase),
      // child: RandomWords(),
      // ),
      // ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrl: 'http://192.168.137.1:8082/address/setting',
          initialHeaders: {},
          onWebViewCreated: (InAppWebViewController controller) {
            controller.addJavaScriptHandler(
                handlerName: "print", callback: (args) {
              print("From the Javascript side:");
              return getCurrentUserLocation();
            });
          },
          onLoadStart: (InAppWebViewController controller, String url) {

          },
          onLoadStop: (InAppWebViewController controller, String url) {

          },
          onConsoleMessage: (InAppWebViewController controller,
              ConsoleMessage consoleMessage) {
            log("Console: ${consoleMessage.message}");
            // Fluttertoast.showToast(msg: message);
          },
        ),
      ),
    );
  }

  Future<Position> getCurrentUserLocation() async {
    return Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((location) {
      return location;
    });
  }
}

/// Stateful 위젯은 위젯의 수명동안 변경될 수 있는 상태를 유지합니다.
/// Stateful 위젯은 최소 두 개 이상 클래스가 필요합니다:
/// 1) StatefulWidget 클래스가 2) State 클래스 의 인스턴스를 생성합니다.
/// StatefulWidget 클래스 그자체는 변경불가능합니다. 하지만 State 클래스가 위젯의 수명동안 상태를 유지합니다.
class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  /// 제안된 단어 쌍을 저장하기 위해 RandomWordsState 클래스에 _suggestions 목록을 추가하세요.
  /// 또한, 글자 크기를 키우기 위해 _biggerFont 변수를 추가하세요.
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  /// ListView 클래스는 builder 속성인 itemBuilder를 제공합니다.
  /// 이 팩토리 빌더는 익명 함수 형태의 콜백 함수를 받습니다. 두 인자가 함수에 전달됩니다; BuildContext와 행 반복자 i입니다.
  /// 반복자는 0부터 시작되고 함수가 호출될 때마다 증가합니다. ListTile에 제안된 모든 단어 쌍에 대해 2번씩, 그리고 Divider에 1번씩 증가합니다.
  /// 이 방식을 사용하여 사용자가 스크롤을 할 때마다 목록이 무한하게 증가할 수 있게 할 수 있습니다.
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),

        /// itemBuilder 콜백은 단어 쌍이 제안될 때마다 호출되고 각각을 ListTile 행에 배치합니다.
        /// 짝수 행인 경우 ListTile 행에 단어 쌍을 추가합니다. 홀수 행인 경우 시각적으로 각 항목을 구분하는 Divider 위젯을 추가합니다.
        /// 작은 기기에서는 구분선을 보기 어려울 수 있습니다.(odd = 홀수, even = 짝수)
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider();
          /*2*/

          /// i ~/ 2 표현식은 i를 2로 나눈 뒤 정수 결과를 반환합니다.
          /// 예를 들어: 1, 2, 3, 4, 5는 0, 1, 1, 2, 2가 됩니다. 이렇게 하면 구분선 위젯을 제외한 ListView에 있는 단어 쌍 수가 계산됩니다.
          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            /// 가능한 단어 쌍을 모두 사용하고 나면, 10개를 더 생성하고 제안 목록에 추가합니다.
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index]);
        });
  }

  /// _buildSuggestions() 함수는 단어 쌍 마다 한 번 씩 _buildRow()를 호출합니다.
  /// 이 함수는 ListTile에서 각각 새로운 쌍을 표시하여 다음 단계에서 행을 더 매력적으로 만들 수 있게 합니다.
  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair); // NEW

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  /// RandomWordsState 클래스에서 build() 메서드를 변경하여 단어 생성 라이브러리를 직접 호출하지 말고 _buildSuggestions()을 사용하도록 하세요,
  /// (Scaffold는 기본적인 머티리얼 디자인 시각 레이아웃을 구현합니다.) 메서드의 본문을 아래 강조 표시된 코드로 교체하세요:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          final tiles = _saved.map(
                (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getPosition();
  // }

  // Future<void> getPosition() async {
  //   var currentPosition = await Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  //   var lastPosition = await Geolocator()
  //       .getLastKnownPosition(desiredAccuracy: LocationAccuracy.low);
  //   print(currentPosition);
  //   print(lastPosition);
  // }
}

