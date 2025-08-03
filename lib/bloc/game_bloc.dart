import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameState.initial()) {
    on<TapCell>(_onTapCell);
    on<RestartGame>(_onRestartGame);
  }

  void _onTapCell(TapCell event, Emitter<GameState> emit) {
    if (state.board[event.index] != '' || state.winner != null) return;

    final updatedBoard = List<String>.from(state.board);
    updatedBoard[event.index] = state.currentPlayer;

    final result = _checkWinner(updatedBoard);
    final nextPlayer = state.currentPlayer == 'X' ? 'O' : 'X';

    emit(state.copyWith(
      board: updatedBoard,
      currentPlayer: result['winner'] == null ? nextPlayer : state.currentPlayer,
      winner: result['winner'],
      winningCombo: result['combo'],
    ));
  }

  void _onRestartGame(RestartGame event, Emitter<GameState> emit) {
    emit(GameState.initial());
  }

  Map<String, dynamic> _checkWinner(List<String> board) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0];
      final b = pattern[1];
      final c = pattern[2];
      if (board[a] != '' && board[a] == board[b] && board[b] == board[c]) {
        return {
          'winner': board[a],
          'combo': pattern,
        };
      }
    }

    return {'winner': null, 'combo': <int>[]};
  }
}
