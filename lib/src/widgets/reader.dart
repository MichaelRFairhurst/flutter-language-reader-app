import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../models/histogram.dart';
import '../models/reader_state.dart';
import '../store/actions.dart';

class Reader extends StatefulWidget {
  Reader({Key key, this.store}) : super(key: key);

  final Store<ReaderState> store;

  @override
  _ReaderState createState() => new _ReaderState();
}

class _ReaderState extends State<Reader> {
  /// Histogram for showing progress/speeds later
  Histogram histogram = new Histogram();

  /// Ticker for rendering the fadein/out of the previous/next [_word]s.
  Ticker ticker;

  /// We have to store this so that we can navigate on a tick event (when we get
  /// to the final [_word].
  BuildContext context;

  _ReaderState() {
    ticker = new Ticker((d) => widget.store.dispatch(new ReaderTickAction(d)));
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new StoreBuilder<ReaderState>(
      builder: (context, store) => new GestureDetector(
            onHorizontalDragStart: (DragStartDetails details) => ticker.start(),
            onHorizontalDragUpdate: (DragUpdateDetails details) => store
                .dispatch(new UpdateDragAmountAction(details.delta.dx, true)),
            onHorizontalDragEnd: (_) {
              store.dispatch(new UpdateDragAmountAction(0.0, false));
              ticker.stop();
            },
            child: new Scaffold(
              appBar: new AppBar(
                title: new Text('Reading'),
              ),
              body: new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new StoreConnector<ReaderState, CloseWords>(
                      converter: closeWords,
                      builder: (context, closeWords) => new Expanded(
                            flex: 3,
                            child: new Center(
                              child: new Stack(
                                alignment: new Alignment(0.0, 0.0),
                                children: words(closeWords),
                              ),
                            ),
                          ),
                    ),
                    new Expanded(
                      flex: 1,
                      child: new Text(
                        'drag to read',
                        style: Theme.of(context).textTheme.display1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  /// The words are not easy to declaratively generate, due to stacked blurs.
  /// Do some math to make the stacked blurs add up to the right blur.
  List<Widget> words(CloseWords words) {
    final result = [];

    // Next word
    if (words.nextWord != null) {
      result.add(
        new Positioned.fill(
          bottom: 0.0,
          top: 0.0,
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  words.nextWord,
                  style: Theme.of(context).textTheme.headline,
                  textScaleFactor: (words.pending + 1 / 2.5) * 2.5,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // previous blur
    var finalBlur = (words.pending + 0.1) * 15;

    // Previous word
    if (words.previousWord != null) {
      // Blurs are inverse, annoyingly. Blur the next word by less than the
      // amount this word will be blurred.
      final nextBlur = (words.progress + 0.5) * 1.5;
      final currentBlur = finalBlur - nextBlur;
      finalBlur = nextBlur;
      result.add(
        new Positioned.fill(
          top: words.progress * 75,
          bottom: 0.0,
          child: new BackdropFilter(
            filter:
                new ImageFilter.blur(sigmaX: currentBlur, sigmaY: currentBlur),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    words.previousWord,
                    style: Theme.of(context).textTheme.headline,
                    textScaleFactor: words.pending / 2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Current word
    result.add(
      new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new BackdropFilter(
              filter:
                  new ImageFilter.blur(sigmaX: finalBlur, sigmaY: finalBlur),
              child: new Text(
                words.currentWord,
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }
}
