part of 'game_board_bloc.dart';

@immutable
abstract class GameBoardState {}

class GameBoardInitial extends GameBoardState {}

class GameBoardPlaying extends GameBoardState {
  final List<GameCell> board;
  final int flags;
  final int bombs;
  final bool gameOver;
  final bool gameWon;

  GameBoardPlaying({
    required this.board,
    this.flags = 0,
    this.bombs = 0,
    this.gameOver = false,
    this.gameWon = false,
  });

  GameBoardPlaying copyWith({
    List<GameCell>? board,
    int? flags,
    int? bombs,
    bool? gameOver,
    bool? gameWon,
  }) {
    return GameBoardPlaying(
      board: board ?? this.board,
      flags: flags ?? this.flags,
      bombs: bombs ?? this.bombs,
      gameOver: gameOver ?? this.gameOver,
      gameWon: gameWon ?? this.gameWon,
    );
  }
}
