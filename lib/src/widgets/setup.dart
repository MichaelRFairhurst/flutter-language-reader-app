import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../navigation.dart';
import '../models/reader_state.dart';
import '../store/actions.dart';

class MySetupPage extends StatelessWidget {
  final editingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  child: _textBox,
                ),
              ),
              new Row(
                children: [
                  new Expanded(
                    child: _startButton,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get _textBox => new StoreBuilder<ReaderState>(
        builder: (context, store) => new TextField(
              maxLines: 10000, // null has a bug
              controller: editingController,
              decoration: new InputDecoration(
                hintText: 'Enter some text for paced reading',
              ),
              onChanged: (s) => store.dispatch(new SetTextAction(s)),
            ),
      );

  Widget get _startButton => new StoreConnector<ReaderState, List<String>>(
        converter: getSentences,
        builder: (context, sentences) => new StoreBuilder<ReaderState>(
              builder: (context, store) => new RaisedButton(
                    onPressed: sentences.isEmpty
                        ? null
                        : () {
                            store.dispatch(SimpleAction.nextSentence);
                            Navigator.of(context).pushNamed(readerRoute);
                          },
                    child: new Text('START'),
                  ),
            ),
      );
}
