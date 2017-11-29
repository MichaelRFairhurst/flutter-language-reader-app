import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';

import '../models/histogram.dart';
import 'reader.dart';

class MyHistogramPage extends StatefulWidget {
  MyHistogramPage({Key key, this.histogram, this.sentence, this.nextSentences})
      : super(key: key);

  final Histogram histogram;
  final List<String> sentence;
  final List<String> nextSentences;

  @override
  _MyHistogramPageState createState() => new _MyHistogramPageState();
}

class _MyHistogramPageState extends State<MyHistogramPage> {
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
            () {
              final _lineChartOptions = new LineChartOptions();
              final _chartData = new ChartData();
              _chartData.dataRowsLegends = [];
              _chartData.dataRows = [widget.histogram.dataRows];
              _chartData.xLabels = widget.histogram.xLabels;
              _chartData.assignDataRowsDefaultColors();
              // Note: ChartOptions.useUserProvidedYLabels default is still used (false);
              return new Expanded(
                  child: new LineChart(
                painter: new LineChartPainter(),
                layouter: new LineChartLayouter(
                    chartData: _chartData, chartOptions: _lineChartOptions),
              ));
            }(),
          ],
        ),
      ),
      floatingActionButton: widget.nextSentences.isEmpty
          ? null
          : new FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    new MaterialPageRoute<Null>(
                        builder: (_) =>
                            new MyReadPage(sentences: widget.nextSentences)));
              },
              child: const Icon(Icons.navigate_next),
            ),
    );
  }

  int get seconds => widget.histogram.duration.inSeconds;
  int get words => widget.sentence.length;
  int get rate => (words / seconds * 60).round();
}
