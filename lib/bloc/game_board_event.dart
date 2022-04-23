part of 'game_board_bloc.dart';

@immutable
abstract class GameBoardEvent {}

class LoadBoard extends GameBoardEvent {}

class CellTapped extends GameBoardEvent {
  final GameCell cell;
  CellTapped(this.cell);
}

class CellLongPress extends GameBoardEvent {
  final GameCell cell;
  CellLongPress(this.cell);
}
