import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:minesweeper/models/game_cell.dart';

part 'game_board_event.dart';
part 'game_board_state.dart';

const int gridSize = 9;
const int numBombs = 10;

class GameBoardBloc extends Bloc<GameBoardEvent, GameBoardState> {
  GameBoardBloc() : super(GameBoardInitial()) {
    on<LoadBoard>(_loadBoard);
    on<CellTapped>(_cellTapped);
    on<CellLongPress>(_cellLongPress);
  }

  FutureOr<void> _loadBoard(LoadBoard event, Emitter<GameBoardState> emit) {
    const int numCells = gridSize * gridSize;
    List<GameCell> board = List.generate(
      numCells,
      (index) => GameCell(
        pos: GridPos(index % gridSize, (index / gridSize).floor() % gridSize),
        numbCloseBombs: index,
      ),
    );

    _generateBombs(board);
    _generateNeighbours(board);
    _countBombsCloseBy(board);

    emit(GameBoardPlaying(board: board, bombs: numBombs));
  }

  void _countBombsCloseBy(List<GameCell> board) {
    for (int i = 0; i < gridSize * gridSize; i++) {
      int count = 0;
      for (int index in board[i].neighbours) {
        if (board[index].isBomb) count++;
      }
      board[i] = board[i].copyWith(numbCloseBombs: count);
    }
  }

  void _generateNeighbours(List<GameCell> board) {
    for (int i = 0; i < gridSize * gridSize; i++) {
      final cell = board[i];
      List<int> neighbours = [];

      for (int x = cell.pos.x - 1; x <= cell.pos.x + 1; x++) {
        for (int y = cell.pos.y - 1; y <= cell.pos.y + 1; y++) {
          if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
            final index = x + (y * gridSize);
            if (index != i) neighbours.add(index);
          }
        }
      }
      board[i] = cell.copyWith(neighbours: neighbours);
    }
  }

  void _generateBombs(List<GameCell> board) {
    int bombCount = 0;
    final rand = Random();
    while (bombCount < numBombs) {
      int index = rand.nextInt(board.length);
      if (!board[index].isBomb) {
        board[index] = board[index].copyWith(isBomb: true);
        bombCount++;
      }
    }
  }

  FutureOr<void> _cellTapped(
      CellTapped event, Emitter<GameBoardState> emit) async {
    final GameCell cell = event.cell;
    final board = (state as GameBoardPlaying).board;
    final index = board.indexOf(cell);

    if (cell.state == CellState.cleared ||
        cell.isFlag ||
        (state as GameBoardPlaying).gameOver) return;

    if (cell.isBomb) {
      return emit((state as GameBoardPlaying).copyWith(gameOver: true));
    }

    if (cell.numbCloseBombs > 0) {
      board[index] = cell.copyWith(state: CellState.cleared);
    }

    if (cell.numbCloseBombs == 0) {
      _clearCellAndNeighbours(board, index);

      for (int i = 0; i < gridSize * gridSize; i++) {
        if (board[i].isFlag) {
          board[i] = board[i].copyWith(state: CellState.unknown);
        }
      }
    }

    emit((state as GameBoardPlaying).copyWith(board: board));
  }

  void _clearCellAndNeighbours(List<GameCell> board, int index) {
    for (int n in board[index].neighbours) {
      if (board[n].state == CellState.unknown) {
        board[n] = board[n].copyWith(state: CellState.cleared);
        if (board[n].numbCloseBombs == 0) {
          _clearCellAndNeighbours(board, n);
        }
      }
    }
  }

  FutureOr<void> _cellLongPress(
      CellLongPress event, Emitter<GameBoardState> emit) async {
    final gameState = state as GameBoardPlaying;
    GameCell cell = event.cell;
    final board = gameState.board;
    final index = board.indexOf(cell);

    if (cell.state == CellState.cleared) return;

    board[index] = cell.copyWith(isFlag: !cell.isFlag);
    int numFlags = board.where((element) => element.isFlag).length;

    if (numFlags == numBombs &&
        board.where((element) => element.isFlag && element.isBomb).length ==
            numBombs) {
      emit(gameState.copyWith(
          board: board, flags: numFlags, gameOver: true, gameWon: true));
    } else {
      emit(gameState.copyWith(board: board, flags: numFlags));
    }
  }
}
