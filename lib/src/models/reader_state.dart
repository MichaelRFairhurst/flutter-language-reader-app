import 'package:redux/redux.dart';
import '../models/histogram.dart';

class ReaderState {
  final String text;
  final int sentenceIndex;
  final double wordPosition;
  final double dragAmount;
  final Histogram currentHistogram;
  final List<Histogram> priorHistograms;

  ReaderState(this.text, this.sentenceIndex, this.wordPosition, this.dragAmount,
      this.currentHistogram, this.priorHistograms);

  ReaderState copyWith(
          {String text,
          int sentenceIndex,
          double wordPosition,
          double dragAmount,
          Histogram currentHistogram,
          List<Histogram> priorHistograms}) =>
      new ReaderState(
          text ?? this.text,
          sentenceIndex ?? this.sentenceIndex,
          wordPosition ?? this.wordPosition,
          dragAmount ?? this.dragAmount,
          currentHistogram ?? this.currentHistogram,
          priorHistograms ?? this.priorHistograms);

  /// Which word we are using ([position] without the [progress]).
  int get word => wordPosition.floor();

  /// How long we've shown the current [word]
  double get progress => wordPosition - word;

  /// How long until we show the next [_word]
  double get pending => 1 - progress;

  List<String> get sentences => new RegExp(r'[^\.?!\s][^\.?!]*([\.?!]+|$)')
      .allMatches(text)
      .map((m) => m.group(0))
      .toList();

  List<String> get currentSentence => sentences[sentenceIndex].split(' ');

  int get wordCount => currentSentence.length;

  CloseWords get closeWords {
    String previousWord = word > 0 ? currentSentence[word - 1] : null;
    String currentWord = currentSentence[word];
    String nextWord =
        currentSentence.length > word + 1 ? currentSentence[word + 1] : null;

    return new CloseWords(
        previousWord, currentWord, nextWord, progress, pending);
  }

  List<List<double>> get dataRows => [
        currentHistogram.speedByTime,
        currentHistogram.progressByTime,
        currentHistogram.wordsByTime,
      ]..addAll(priorHistograms.map((h) => h.speedByTime));

  int get seconds => currentHistogram.duration.inSeconds;

  SummaryStats get summaryStats => new SummaryStats(wordCount, seconds);
  SummaryGraphData get summaryGraphData => new SummaryGraphData(
      currentHistogram.xLabels, dataRows, priorHistograms.length);
}

class CloseWords {
  final String currentWord;
  final String previousWord;
  final String nextWord;
  final double progress;
  final double pending;

  CloseWords(this.previousWord, this.currentWord, this.nextWord, this.progress,
      this.pending);
}

class SummaryStats {
  final int words;
  final int seconds;
  SummaryStats(this.words, this.seconds);
}

class SummaryGraphData {
  final List<String> xLabels;
  final List<List<double>> dataRows;
  final int priorHistogramsCount;
  SummaryGraphData(this.xLabels, this.dataRows, this.priorHistogramsCount);
}

List<String> getSentences(Store<ReaderState> s) => s.state.sentences;
List<String> getCurrentSentence(Store<ReaderState> s) =>
    s.state.currentSentence;
bool isDone(Store<ReaderState> s) =>
    s.state.sentenceIndex == getSentences(s).length - 1;
int wordCount(Store<ReaderState> s) => getCurrentSentence(s).length;
CloseWords closeWords(Store<ReaderState> s) => s.state.closeWords;

SummaryStats summaryStats(Store<ReaderState> s) => s.state.summaryStats;
SummaryGraphData summaryGraphData(Store<ReaderState> s) =>
    s.state.summaryGraphData;
