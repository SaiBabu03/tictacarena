abstract class GameEvent {}

class TapCell extends GameEvent {
  final int index;
  TapCell(this.index);
}

class RestartGame extends GameEvent {}
