import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../models/reader_state.dart';
import '../store/actions.dart';

class Histogram extends StatelessWidget {
  Histogram({Key key}) : super(key: key);

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
              child: new StoreConnector<ReaderState, bool>(
                converter: isDone,
                builder: (context, done) => new Text(
                      done
                          ? 'You completed the reading!'
                          : 'Sentence completed!',
                      style: Theme.of(context).textTheme.display1,
                      textAlign: TextAlign.center,
                    ),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.only(bottom: 10.0),
              child: new StoreConnector<ReaderState, SummaryStats>(
                converter: summaryStats,
                builder: (context, stats) => new Text(
                      'Time: ${stats.seconds}\n'
                          'Words: ${stats.words}\n'
                          'Wpm: ${getRate(stats.words, stats.seconds)}',
                      style: Theme.of(context).textTheme.headline,
                      textAlign: TextAlign.center,
                    ),
              ),
            ),
            new Expanded(
              child: new StoreConnector<ReaderState, SummaryGraphData>(
                converter: summaryGraphData,
                builder: (context, graphData) => new LineChart(
                      painter: new LineChartPainter(),
                      layouter: new LineChartLayouter(
                          chartData: _chartData
                            ..dataRows = graphData.dataRows
                            ..xLabels = graphData.xLabels
                            ..dataRowsColors = getDataRowsColors(
                                graphData.priorHistogramsCount),
                          chartOptions: _lineChartOptions),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new StoreConnector<ReaderState, bool>(
        converter: isDone,
        builder: (context, done) => done
            ? new Container()
            : new StoreBuilder<ReaderState>(
                builder: (context, store) => new FloatingActionButton(
                      onPressed: () {
                        store.dispatch(SimpleAction.nextSentence);
                        Navigator.of(context).pushReplacementNamed("read");
                      },
                      child: const Icon(Icons.navigate_next),
                    ),
              ),
      ),
    );
  }

  int getRate(int words, int seconds) => (words / seconds * 60).round();

  List<ui.Color> getDataRowsColors(int priorHistogramsCount) => [
        Colors.blue, // speed
        Colors.cyan, // progress
        Colors.lime // word
        // one blueGrey for each prior histogram
      ]..addAll(
          new List.generate(priorHistogramsCount, (_) => Colors.blueGrey));
}
