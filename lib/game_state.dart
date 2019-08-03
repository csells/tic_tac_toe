import 'dart:async';
import 'package:mobx/mobx.dart';

// Include generated file
part 'game_state.g.dart';

// This is the class used by rest of your codebase
class GameState = _GameState with _$GameState;

// The store-class
abstract class _GameState with Store {
  DateTime _started;
  Timer _timer;

  @observable
  String player;

  @observable
  var pieces = ObservableList<String>.of([null, null, null, null, null, null, null, null, null]);

  @observable
  List<int> winnerPieces;

  @observable
  var gameDuration;

  _GameState() {
    reset();
  }

  @action
  void reset() {
    pieces.fillRange(0, pieces.length, null);
    winnerPieces = null;
    player = 'X';
    _started = DateTime.now();
    gameDuration = Duration(seconds: 0);

    if (_timer != null) _timer.cancel();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (_) => gameDuration = DateTime.now().difference(_started),
    );
  }

  @observable
  String get winner => winnerPieces == null ? null : pieces[winnerPieces[0]];

  @observable
  bool get gameOver => winner != null || pieces.every((p) => p != null);

  @observable
  String get status => "It's $player's turn: ${_durationFormat(gameDuration)}";

  static String _durationFormat(Duration diff) {
    var full = diff == null ? "." : diff.toString();
    return full.substring(0, full.indexOf('.'));
  }

  static const List<List<int>> _wins = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // by row
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // by column
    [0, 4, 8], [2, 4, 6], // by diagonal
  ];

  void move(int pos) {
    assert(!gameOver);
    assert(pieces[pos] == null);

    // store the move and check for a winner
    pieces[pos] = player;
    for (var win in _wins) {
      if (win.every((p) => pieces[p] == player)) {
        winnerPieces = win;
        break;
      }
    }

    // if the game isn't over, switch players
    if (!gameOver) {
      player = player == 'X' ? 'O' : 'X';
    }
  }
}
