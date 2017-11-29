import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'histogram.dart';
import '../models/histogram.dart';
import 'speed.dart';

class MyReadPage extends StatefulWidget {
  MyReadPage(
      {Key key, List<String> sentences, this.previousHistograms = const []})
      : text = sentences[0].split(' '),
        nextSentences = sentences.sublist(1, sentences.length),
        super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final List<String> text;
  final List<String> nextSentences;
  final List<Histogram> previousHistograms;

  @override
  _MyReadPageState createState() => new _MyReadPageState();
}

class _MyReadPageState extends State<MyReadPage> {
  Histogram histogram = new Histogram();
  int _word = 0;
  double dragamt = 0.0;
  double rollover = 1.0;

  Function() delayed = () {};

  Function() _incrementCounterOrLeave(BuildContext context) =>
      _word == widget.text.length - 1 ? () => done(context) : increment;

  void done(BuildContext context) {
    histogram.done();
    Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
        builder: (_) => new MyHistogramPage(
            histogram: histogram,
            sentence: widget.text,
            nextSentences: widget.nextSentences,
            previousHistograms: widget.previousHistograms)));
    reset();
  }

  void increment() => setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _word without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        histogram.report(new WordReadEvent(_word++));
      });

  void _handleDrag(DragUpdateDetails details, BuildContext context) {
    dragamt += details.delta.dx;
    _handleRolloverLoop(context);
  }

  void _handleRolloverLoop(BuildContext context) {
    _handleRollover(context);
    delayed = () => _handleRolloverLoop(context);
    new Future.delayed(const Duration(milliseconds: 40)).then((_) {
      delayed();
    });
  }

  void _handleRollover(BuildContext context) {
    rollover -= dragamt / 60000;
    if (rollover < 0) {
      rollover = 1.0;
      _incrementCounterOrLeave(context)();
    } else if (rollover > 1) {
      rollover = 0.0;
      if (_word > 0) {
        setState(() => _word--);
        return;
      }
    }
    setState(() {}); // rerender
  }

  void reset() {
    dragamt = 0.0;
    delayed = () {};
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails details) =>
          _handleDrag(details, context),
      onHorizontalDragEnd: (_) => reset(),
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Reading'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                flex: 3,
                child: new Center(
                  child: new Stack(
                    alignment: new Alignment(0.0, 0.0),
                    children: words(),
                  ),
                ),
              ),
              new Expanded(
                flex: 1,
                child: new CustomPaint(
                  painter: new SpeedPainter(dragamt),
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
    );
  }

  List<Widget> words() {
    final result = [];

    // Next word
    if (widget.text.length > _word + 1) {
      result.add(
        new Positioned.fill(
          bottom: 0.0,
          top: 0.0,
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  widget.text[_word + 1],
                  style: Theme.of(context).textTheme.headline,
                  textScaleFactor: (rollover + 1 / 2.5) * 2.5,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // previous blur
    var finalBlur = (rollover + 0.1) * 15;

    // Previous word
    if (_word > 0) {
      // Blurs are inverse, annoyingly. Blur the next word by less than the
      // amount this word will be blurred.
      final nextBlur = ((1 - rollover) + 0.5) * 1.5;
      final currentBlur = finalBlur - nextBlur;
      finalBlur = nextBlur;
      result.add(
        new Positioned.fill(
          top: (1 - rollover) * 75,
          bottom: 0.0,
          child: new BackdropFilter(
            filter:
                new ImageFilter.blur(sigmaX: currentBlur, sigmaY: currentBlur),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    widget.text[_word - 1],
                    style: Theme.of(context).textTheme.headline,
                    textScaleFactor: rollover / 2,
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
                widget.text[_word],
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
