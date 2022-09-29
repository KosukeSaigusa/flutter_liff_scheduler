import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_liff/flutter_line_liff.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:duration_picker/duration_picker.dart';

class Affair {
  Affair(this.title, this.time, this.period, this.summary, this.description) {}
  String title;
  DateTime time;
  Duration period;
  String summary;
  String description;
}

// 以下は表示機能実装の為の仮のデータ。
// GASに実装されたWeb APIを通してイベント情報の、GAS側への書き込みとGAS側からの読み出しを行うコードを実装予定。
List<Affair> affairs = [
  Affair("公園掃除", DateTime(2022, 10, 2, 0, 0, 0), const Duration(hours: 2),
      "いつもの作業", "最近参加者が少ないので、なるべく参加するようにしてください。"),
  Affair("火の用心", DateTime(2022, 10, 3, 20, 0, 0), const Duration(hours: 1),
      "防災週間です", "3丁目と4丁目を見回ります。いつもの蛍光服でご参加下さい。"),
  Affair("合唱練習", DateTime(2022, 10, 4, 10, 30, 0), const Duration(hours: 2),
      "わかくさ幼稚園の運動会で合唱を披露します", "子どもたちに喜んでもらえるよう、しっかり練習しましょう。"),
  Affair("運動会", DateTime(2022, 10, 20, 8, 30, 0), const Duration(hours: 4),
      "わかくさ幼稚園運動会", "年に一度の大運動会開催！　合唱団のメンバーは必ず参加してください。\n合唱は10:00から"),
  Affair("忘年会", DateTime(2022, 11, 23, 19, 0, 0), const Duration(hours: 2),
      "今年はやるよ", "コロナ禍で開催を止めていたけど、もう我慢できない！ 場所は大漁節2階。会話はマスクを付けて行ってください。"),
  Affair("新年会", DateTime(2023, 1, 20, 18, 30, 0), const Duration(hours: 2),
      "来年はやるよ", "場所はいつもの大漁節2階。参加費用は大人3000円子ども1000円です。"),
];
Affair editAffair = Affair("", DateTime.now(), Duration(hours: 2), "", "");

String groupId = '';

Future<void> main() async {
  await dotenv.load(fileName: 'env');
  String id = dotenv.get('LIFFID', fallback: 'LIFFID not found');

  // liff用JavaqScriptライブラリをJS()を用いて直接利用するつもりでしたが、JS()の理解が難しかったので、時間を節約するためにflutter_line_liffパッケージをを使用しました
  await FlutterLineLiff().init(
    config: Config(liffId: id),
    errorCallback: (error) {
      // TODO: エラーメッセージを表示する。
      // その後、アプリを強制終了させる。
    },
  );
  Context? liffContext = FlutterLineLiff().context;
  if (liffContext != null) {
    if (liffContext.type == 'group') {
      groupId = liffContext.groupId ?? '';
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'グループトーク内行事共有',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '行事一覧'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _headerStyle = const TextStyle(
      color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
  final _contentStyleHeader = const TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  final _contentStyle = const TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);
  final _loremIpsum =
      '''Lorem ipsum is typically a corrupted version of 'De finibus bonorum et malorum', a 1st century BC text by the Roman statesman and philosopher Cicero, with words altered, added, and removed to make it nonsensical and improper Latin.''';

  EditDialog(BuildContext context, int idx) async {
    DateTime localTime = editAffair.time.toLocal();
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("表題: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    margin: EdgeInsets.only(left: 50),
                    child: TextField(
                      controller: TextEditingController(text: editAffair.title),
                      onChanged: (value) {
                        editAffair.title = value;
                      },
                      decoration: InputDecoration(hintText: 'ここに表題を入力してください'),
                    ),
                  ),
                ]),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text("行事日時: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime:
                              DateTime(DateTime.now().year - 2, 1, 1, 0, 0),
                          maxTime:
                              DateTime(DateTime.now().year + 2, 12, 31, 23, 59),
                          onConfirm: (date) {
                        setState(() {
                          editAffair.time = date;
                          localTime = editAffair.time.toLocal();
                        });
                      }, locale: LocaleType.jp);
                    },
                    child: Text(
                        '${localTime.year}/${localTime.month}/${localTime.day} ${localTime.hour}:${localTime.minute}',
                        style: _contentStyle),
                  ),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("行事時間: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () async {
                        var resultingDuration = await showDurationPicker(
                          context: context,
                          initialTime: editAffair.period,
                        );
                        if (resultingDuration != null) {
                          setState(() {
                            editAffair.period = resultingDuration;
                          });
                        }
                      },
                      child: Text("${editAffair.period.inMinutes}分間",
                          style: _contentStyle),
                    )
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("簡単な説明:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    margin: EdgeInsets.only(left: 50),
                    child: TextField(
                      controller:
                          TextEditingController(text: editAffair.summary),
                      onChanged: (value) {
                        editAffair.summary = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'ここに簡単な説明を入力してください',
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 5),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("丁寧な説明:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    margin: EdgeInsets.only(left: 50),
                    child: TextField(
                      controller:
                          TextEditingController(text: editAffair.description),
                      onChanged: (value) {
                        editAffair.description = value;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'ここに丁寧な説明を入力してください',
                      ),
                    ),
                  ),
                ]),
              ],
            )),
            actions: <Widget>[
              TextButton(
                child: idx == -1 ? Text('追加') : Text('編集'),
                onPressed: () {
                  setState(() {
                    if (idx == -1) {
                      affairs.add(editAffair);
                    } else {
                      affairs[idx] = editAffair;
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('キャンセル'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  AccordionSection GenAccordionSection(int idx) {
    DateTime local = affairs[idx].time.toLocal();
    return AccordionSection(
      isOpen: false,
      index: idx,
      leftIcon: const Icon(Icons.event, color: Colors.black),
      rightIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
      headerBackgroundColor: Colors.lightBlue[100],
      headerBackgroundColorOpened: Colors.lightBlue,
      header: Text(
          '${local.year}/${local.month}/${local.day} ${local.hour}:${local.minute} ${affairs[idx].title}',
          style: _headerStyle),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("行事時間: ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${affairs[idx].period.inMinutes}分間"),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("簡単な説明:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                margin: EdgeInsets.only(left: 50),
                child: Text("${affairs[idx].summary}", style: _contentStyle),
              ),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("丁寧な説明:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                margin: EdgeInsets.only(left: 50),
                child: Text("${affairs[idx].description}"),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                    onPressed: () {
                      editAffair = affairs[idx];
                      EditDialog(context, idx);
                    },
                    icon: Icon(Icons.edit),
                    label: Text("編集")),
                TextButton.icon(
                    onPressed: () {
                      setState(() {
                        affairs.removeAt(idx);
                      });
                    },
                    icon: Icon(Icons.delete),
                    label: Text("削除")),
              ],
            )
          ],
        ),
      ),
      contentHorizontalPadding: 20,
      contentBorderWidth: 1,
      // onOpenSection: () => print('onOpenSection ...'),
      // onCloseSection: () => print('onCloseSection ...'),));
    );
  }

  List<AccordionSection> GenAccordionList() {
    List<AccordionSection> list = <AccordionSection>[];
    for (int i = 0; i < affairs.length; i++) {
      list.add(GenAccordionSection(i));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        //foregroundColor: Colors.black,
        title: Text(widget.title),
      ),
      body: Center(
          child: Accordion(
        maxOpenSections: 2,
        headerBackgroundColor: Colors.blue,
        headerBackgroundColorOpened: Colors.amber,
        scaleWhenAnimating: true,
        openAndCloseAnimation: true,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
        sectionClosingHapticFeedback: SectionHapticFeedback.light,
        children: GenAccordionList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          editAffair = Affair("", DateTime.now(), Duration(hours: 2), "", "");
          EditDialog(context, -1);
        },
        tooltip: '行事追加',
        mini: true,
        child: const Icon(Icons.event),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
