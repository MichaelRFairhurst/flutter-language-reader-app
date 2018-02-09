enum SimpleAction { nextSentence }

class SetTextAction {
  final String text;
  SetTextAction(this.text);
}

class ReaderTickAction {
  Duration duration;
  ReaderTickAction(this.duration);
}

class UpdateDragAmountAction {
  double dragAmount;
  bool isRelative;
  UpdateDragAmountAction(this.dragAmount, this.isRelative);
}
