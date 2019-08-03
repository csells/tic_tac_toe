import 'package:mobx/mobx.dart';

// Include generated file
part 'game_state.g.dart';

// This is the class used by rest of your codebase
class GameState = _GameState with _$GameState;

// The store-class
abstract class _GameState with Store {
  DateTime _started;
  //Timer _timer;

  @observable
  String player;

  @observable
  var pieces = ObservableList<String>.of([null,null,null,null,null,null,null,null,null,]);

  @observable
  List<int> winnerPieces;

  _GameState() {
    reset();
  }

  @observable
  String get winner => winnerPieces == null ? null : pieces[winnerPieces[0]];

  @observable
  bool get gameOver => winner != null || pieces.every((p) => p != null);

  @observable
  String get status => "It's $player's turn: ${_durationFormatFrom(_started, "HH:MM:SS")}";

  String _durationFormatFrom(DateTime dt, String format) {
    assert(format == "HH:MM:SS"); // that's all we're handling right now...
    var full = DateTime.now().difference(dt).toString();
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

  void reset() {
    pieces.fillRange(0, pieces.length, null);
    winnerPieces = null;
    player = 'X';
    _started = DateTime.now();

    // TODO: what's best here?
    //if (_timer != null) _timer.cancel();
    //_timer = Timer.periodic(Duration(seconds: 1), (_) => notifyListeners());
  }
}
