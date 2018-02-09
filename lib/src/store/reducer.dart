import '../models/reader_state.dart';
import 'actions.dart';
import '../navigation.dart';
import '../models/histogram.dart';

ReaderState reduceAnything(ReaderState s, dynamic a) {
  if (a is SimpleAction) {
    return reduceSimpleAction(s, a);
  }
  if (a is SetTextAction) {
    return reduceSetTextAction(s, a);
  }
  if (a is ReaderTickAction) {
    return reduceReaderTickAction(s, a);
  }
  if (a is UpdateDragAmountAction) {
    return reduceUpdateDragAmountAction(s, a);
  }
  return s;
}

ReaderState reduceSimpleAction(ReaderState s, SimpleAction a) {
  switch (a) {
    case SimpleAction.nextSentence:
      return s.copyWith(
          sentenceIndex: s.sentenceIndex + 1,
          currentHistogram: new Histogram(),
          wordPosition: 0.0);
  }
  return s;
}

ReaderState reduceSetTextAction(ReaderState s, SetTextAction a) {
  return s.copyWith(
      text: a.text, sentenceIndex: -1, wordPosition: 0.0, dragAmount: 0.0);
}

ReaderState reduceReaderTickAction(ReaderState s, ReaderTickAction a) {
  final lastword = s.word;
  var position =
      s.wordPosition + s.dragAmount / 5000000 * a.duration.inMilliseconds;
  var histogram = s.currentHistogram;
  final repositionedOnlyState = s.copyWith(wordPosition: position);

  if (repositionedOnlyState.word == s.currentSentence.length) {
    position = s.currentSentence.length.toDouble() - 1;
    histogram = new Histogram(
        wordReadEvents: s.currentHistogram.wordReadEvents,
        endTime: new DateTime.now());
    navigatorKey.currentState.pushReplacementNamed('histogram');
  } else if (position < 0) {
    position = 0.0;
  } else if (lastword != repositionedOnlyState.word) {
    histogram = new Histogram(
        wordReadEvents:
            new List<WordReadEvent>.from(s.currentHistogram.wordReadEvents)
              ..add(new WordReadEvent(repositionedOnlyState.word)));
  }

  return s.copyWith(wordPosition: position, currentHistogram: histogram);
}

ReaderState reduceUpdateDragAmountAction(
        ReaderState s, UpdateDragAmountAction a) =>
    s.copyWith(dragAmount: (a.isRelative ? s.dragAmount : 0.0) + a.dragAmount);
