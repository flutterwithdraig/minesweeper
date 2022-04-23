import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minesweeper/models/game_cell.dart';

import 'bloc/game_board_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppHome(),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBoardBloc()..add(LoadBoard()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<GameBoardBloc, GameBoardState>(
            builder: (context, state) {
              if (state is GameBoardPlaying) {
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: GridView.count(
                        crossAxisCount: 9,
                        childAspectRatio: 1,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        children: state.board.map((cell) {
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<GameBoardBloc>()
                                  .add(CellTapped(cell));
                            },
                            onLongPress: () {
                              context
                                  .read<GameBoardBloc>()
                                  .add(CellLongPress(cell));
                            },
                            child: Container(
                              color: cell.isBomb && state.gameOver
                                  ? Colors.red
                                  : cell.state == CellState.unknown
                                      ? Colors.grey[500]
                                      : Colors.grey[350],
                              child: Center(
                                child: cellContent(cell),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (state.gameOver) ...[
                      const Text('Game Over'),
                      if (state.gameWon) ...[
                        const Text('You won'),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          context.read<GameBoardBloc>().add(LoadBoard());
                        },
                        child: const Text('Play Again'),
                      )
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flag),
                          Text((state.bombs - state.flags).toString()),
                        ],
                      )
                    ]
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget? cellContent(GameCell cell) {
    if (cell.isFlag) {
      return const Icon(Icons.flag);
    }
    return cell.numbCloseBombs > 0 && !cell.isBomb
        ? cell.state == CellState.unknown
            ? null
            : Text(cell.numbCloseBombs.toString())
        : null;
  }
}
