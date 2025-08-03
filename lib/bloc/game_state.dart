class GameState {
  final List<String> board;
  final String currentPlayer;
  final String? winner;
  final List<int> winningCombo;

  bool get isDraw => !board.contains('') && winner == null;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.winner,
    required this.winningCombo,
  });

  factory GameState.initial() {
    return GameState(
      board: List.filled(9, ''),
      currentPlayer: 'X',
      winner: null,
      winningCombo: [],
    );
  }

  GameState copyWith({
    List<String>? board,
    String? currentPlayer,
    String? winner,
    List<int>? winningCombo,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner,
      winningCombo: winningCombo ?? this.winningCombo,
    );
  }
}
