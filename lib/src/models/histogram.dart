import 'dart:collection';

class Histogram {
  final DateTime _startTime = new DateTime.now();
  final _wordReadEvents = <WordReadEvent>[];

  void report(WordReadEvent readEvent) {
    assert(_endTime == null);
    _wordReadEvents.add(readEvent);
  }

  void done() {
    assert(_endTime == null);
    _endTime = new DateTime.now();
  }

  DateTime _endTime;

  Duration get duration => _endTime.difference(_startTime);

  List<double> get dataRows {
    final result = <double>[];

    for (final time in new _HistogramTimeIterator(this)) {
      final lastEventIndex = _wordReadEvents
              .takeWhile((ev) => ev.timeRead.compareTo(time) != 1)
              .toList()
              .length -
          1;
      final wordsAtEvent =
          lastEventIndex == -1 ? 0 : _wordReadEvents[lastEventIndex].index;

      result.add(wordsAtEvent.toDouble());
    }

    return result;
  }

  List<String> get xLabels =>
      new _HistogramTimeIterator(this).map((t) => t.toString()).toList();
}

class WordReadEvent {
  final DateTime timeRead = new DateTime.now();
  final int index;

  WordReadEvent(this.index);
}

class _HistogramTimeIterator extends IterableMixin<DateTime>
    implements Iterator<DateTime>, Iterable<DateTime> {
  final DateTime _end;
  final Duration interval;

  _HistogramTimeIterator(Histogram histogram, {int steps: 20})
      : this.exactInterval(
            histogram,
            new Duration(
                milliseconds:
                    (histogram.duration.inMilliseconds / steps).ceil()));

  _HistogramTimeIterator.exactInterval(Histogram histogram, this.interval)
      : current = histogram._startTime,
        _end = histogram._endTime;

  DateTime current;

  bool moveNext() {
    if (current == _end) {
      return false;
    }

    current = current.add(interval);

    if (current.isAfter(_end)) {
      current = _end;
    }

    return true;
  }

  Iterator<DateTime> get iterator => this;
}
