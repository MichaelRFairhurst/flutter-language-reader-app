import 'package:flutter/material.dart';

import 'reader.dart';

class MySetupPage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MySetupPageState createState() => new _MySetupPageState();
}

class _MySetupPageState extends State<MySetupPage> {
  String _text = '';
  void _action(String text) {
    setState(() {
      _text = text;
    });
  }

  final _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    print(sentences);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Enter text to read'),
      ),
      body: new Center(
        child: new Container(
          margin: new EdgeInsets.all(4.0),
          decoration: const BoxDecoration(
            border: const Border(
              top: const BorderSide(width: 2.0, color: Colors.grey),
              left: const BorderSide(width: 2.0, color: Colors.grey),
              right: const BorderSide(width: 2.0, color: Colors.grey),
              bottom: const BorderSide(width: 2.0, color: Colors.grey),
            ),
          ),
          child: new Column(
            children: [
              new Expanded(
                child: new Container(
                  padding: new EdgeInsets.all(4.0),
                  child: new TextField(
                    maxLines: 10000, // null has a bug
                    controller: _controller,
                    decoration: new InputDecoration(
                      hintText: 'Enter some text for paced reading',
                    ),
                    onChanged: _action,
                  ),
                ),
              ),
              new Row(
                children: [
                  new Expanded(
                    child: new RaisedButton(
                      onPressed: sentences.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                    new MaterialPageRoute<Null>(
                                      builder: (_) =>
                                          new MyReadPage(sentences: sentences),
                                    ),
                                  );
                            },
                      child: new Text('START'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<String> get sentences => new RegExp(r'[^\.?!\s][^\.?!]*([\.?!]+|$)')
      .allMatches(_text)
      .map((m) => m.group(0))
      .toList();
}
