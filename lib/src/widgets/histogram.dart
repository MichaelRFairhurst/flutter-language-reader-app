import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';

import '../models/histogram.dart';
import 'reader.dart';

class MyHistogramPage extends StatefulWidget {
  MyHistogramPage(
      {Key key,
      this.histogram,
      this.sentence,
      this.nextSentences,
      this.previousHistograms})
      : super(key: key);

  final Histogram histogram;
  final List<Histogram> previousHistograms;
  final List<String> sentence;
  final List<String> nextSentences;

  @override
  _MyHistogramPageState createState() => new _MyHistogramPageState();
}

class _MyHistogramPageState extends State<MyHistogramPage> {
  final _lineChartOptions = new LineChartOptions()
    ..hotspotOuterRadius = 5.0
    ..hotspotOuterPaint = (new Paint()..color = Colors.blueGrey)
    ..hotspotInnerRadius = 3.0
    ..hotspotInnerPaint = (new Paint()..color = Colors.grey);
  final _chartData = new ChartData()
    ..dataRowsLegends = ['Speed', 'Progress', 'Word', 'Last Speeds'];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Reading completed!'),
      ),
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.symmetric(vertical: 15.0),
              child: new Text(
                widget.nextSentences.isEmpty
                    ? 'You completed the reading!'
                    : 'Sentence completed!',
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(bottom: 10.0),
              child: new Text(
                'Time: $seconds\n'
                    'Words: $words\n'
                    'Wpm: $rate',
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              ),
            ),
            new Expanded(
              child: new LineChart(
                painter: new LineChartPainter(),
                layouter: new LineChartLayouter(
                    chartData: _chartData
                      ..dataRows = dataRows
                      ..xLabels = widget.histogram.xLabels
                      ..dataRowsColors = dataRowsColors,
                    chartOptions: _lineChartOptions),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.nextSentences.isEmpty
          ? null
          : new FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    new MaterialPageRoute<Null>(
                        builder: (_) => new MyReadPage(
                            sentences: widget.nextSentences,
                            previousHistograms:
                                new List.from(widget.previousHistograms)
                                  ..add(widget.histogram))));
              },
              child: const Icon(Icons.navigate_next),
            ),
    );
  }

  List<List<double>> get dataRows => [
        widget.histogram.speedByTime,
        widget.histogram.progressByTime,
        widget.histogram.wordsByTime,
      ]..addAll(widget.previousHistograms.map((h) => h.speedByTime));

  List<ui.Color> get dataRowsColors => [
        Colors.blue, // speed
        Colors.cyan, // progress
        Colors.lime // word
      ]..addAll(widget.previousHistograms.map((h) => Colors.blueGrey));

  int get seconds => widget.histogram.duration.inSeconds;
  int get words => widget.sentence.length;
  int get rate => (words / seconds * 60).round();
}
