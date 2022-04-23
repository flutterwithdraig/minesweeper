class GridPos {
  final int x;
  final int y;

  GridPos(this.x, this.y);

  @override
  String toString() {
    return "$x, $y";
  }
}

enum CellState {
  unknown,
  cleared,
}

class GameCell {
  final bool isBomb;
  final GridPos pos;
  final List<int> neighbours;
  final int numbCloseBombs;
  final CellState state;
  final bool isFlag;

  const GameCell({
    this.isBomb = false,
    required this.pos,
    this.neighbours = const [],
    this.numbCloseBombs = 0,
    this.state = CellState.unknown,
    this.isFlag = false,
  });

  GameCell copyWith({
    bool? isBomb,
    GridPos? pos,
    List<int>? neighbours,
    int? numbCloseBombs,
    CellState? state,
    bool? isFlag,
  }) {
    return GameCell(
      isBomb: isBomb ?? this.isBomb,
      pos: pos ?? this.pos,
      neighbours: neighbours ?? this.neighbours,
      numbCloseBombs: numbCloseBombs ?? this.numbCloseBombs,
      state: state ?? this.state,
      isFlag: isFlag ?? this.isFlag,
    );
  }
}
