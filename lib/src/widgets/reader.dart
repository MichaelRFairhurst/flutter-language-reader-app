import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'histogram.dart';
import '../models/histogram.dart';

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
  /// Histogram for showing progress/speeds later
  Histogram histogram = new Histogram();

  /// Ticker for rendering the fadein/out of the previous/next [_word]s.
  Ticker ticker;

  /// We have to store this so that we can navigate on a tick event (when we get
  /// to the final [_word].
  BuildContext context;

  _MyReadPageState() {
    ticker = new Ticker(_step);
  }

  /// Which word we are showing, including fractional [_progress].
  double position = 0.0;

  /// Which word we are using ([position] without the [_progress]).
  int get _word => position.floor();

  /// How long we've shown the current [_word]
  double get _progress => position - _word;

  /// How long until we show the next [_word]
  double get _pending => 1 - _progress;

  /// How quickly we're progressing, based on the amount dragged.
  double dragamt = 0.0;

  /// Finalize the histogram, and show it in the page.
  void done() {
    histogram.done();
    Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
        builder: (_) => new MyHistogramPage(
            histogram: histogram,
            sentence: widget.text,
            nextSentences: widget.nextSentences,
            previousHistograms: widget.previousHistograms)));
    ticker.stop();
    position = widget.text.length.toDouble() - 1;
  }

  /// Called by [ticker] to adjust the [position] based on [dragamt] and
  /// [duration] since last tick.
  void _step(Duration duration) {
    setState(() {
      final lastword = _word;
      position += dragamt / 5000000 * duration.inMilliseconds;
      if (_word == widget.text.length) {
        done();
      } else if (position < 0) {
        position = 0.0;
      } else if (lastword != _word) {
        histogram.report(new WordReadEvent(_word));
      }
    });
  }

  void reset() {
    dragamt = 0.0;
    ticker.stop();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) => ticker.start(),
      onHorizontalDragUpdate: (DragUpdateDetails details) =>
          dragamt += details.delta.dx,
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

  /// The words are not easy to declaratively generate, due to stacked blurs.
  /// Do some math to make the stacked blurs add up to the right blur.
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
                  textScaleFactor: (_pending + 1 / 2.5) * 2.5,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // previous blur
    var finalBlur = (_pending + 0.1) * 15;

    // Previous word
    if (_word > 0) {
      // Blurs are inverse, annoyingly. Blur the next word by less than the
      // amount this word will be blurred.
      final nextBlur = (_progress + 0.5) * 1.5;
      final currentBlur = finalBlur - nextBlur;
      finalBlur = nextBlur;
      result.add(
        new Positioned.fill(
          top: _progress * 75,
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
                    textScaleFactor: _pending / 2,
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
