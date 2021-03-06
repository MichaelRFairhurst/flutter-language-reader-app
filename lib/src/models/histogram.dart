import 'dart:collection';

class Histogram {
  DateTime get startTime => wordReadEvents.first.timeRead;
  final List<WordReadEvent> wordReadEvents;
  final DateTime endTime;

  Histogram({this.wordReadEvents = const <WordReadEvent>[], this.endTime});

  Duration get duration => endTime.difference(startTime);

  List<double> get wordsByTime => new _HistogramTimeIterator(this).map((time) {
        final lastEventIndex = wordReadEvents
                .takeWhile((ev) => !ev.timeRead.isAfter(time))
                .toList()
                .length -
            1;
        final wordsAtEvent =
            lastEventIndex == -1 ? 0 : wordReadEvents[lastEventIndex].index;

        return wordsAtEvent.toDouble();
      }).toList();

  List<double> get progressByTime => new _HistogramTimeIterator(this)
      .map((time) => wordReadEvents.reversed
          .takeWhile((ev) => ev.timeRead.isAfter(time))
          .map((ev) => ev.index)
          .fold(
              wordReadEvents
                      .lastWhere((ev) => !ev.timeRead.isAfter(time),
                          orElse: () => null)
                      ?.index ??
                  0,
              (acc, x) => x < acc ? x : acc))
      .map((i) => i.toDouble())
      .toList();

  List<double> get speedByTime => new _HistogramTimeIterator(this).map((time) {
        final events =
            wordReadEvents.takeWhile((ev) => !ev.timeRead.isAfter(time));
        return events.isEmpty
            ? 0.0
            : events.last.index /
                (time.difference(startTime).inSeconds.toDouble() + 1);
      }).toList();

  List<String> get xLabels => new _HistogramTimeIterator(this)
      .map((t) => t.difference(startTime).inSeconds)
      .fold(
          [],
          (acc, seconds) => acc
            ..add(acc.lastWhere((i) => i != null, orElse: () => null) == seconds
                ? null
                : seconds))
      .map((seconds) => seconds == null ? '' : "${seconds}s")
      .toList();
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
  int i = 0;

  _HistogramTimeIterator(Histogram histogram, {int steps: 20})
      : this.exactInterval(
            histogram,
            new Duration(
                microseconds:
                    (histogram.duration.inMicroseconds / steps).ceil()));

  _HistogramTimeIterator.exactInterval(Histogram histogram, this.interval)
      : current = histogram.startTime,
        _end = histogram.endTime;

  DateTime current;

  bool moveNext() {
    if (current == _end) {
      return false;
    }

    current = current.add(interval);

    if (current.isAfter(_end) || current.isAtSameMomentAs(_end)) {
      current = _end;
    }

    return true;
  }

  Iterator<DateTime> get iterator => this;
}
