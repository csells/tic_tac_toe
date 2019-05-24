import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'dart:async';
//import 'package:intl/intl.dart'; TODO: use DateFormat.durationFormatFrom when it's implemented...

class GameState extends ChangeNotifier {
  var _pieces = List<String>(9);
  String _player;
  List<int> _winnerPieces;
  DateTime _started;
  Timer _timer;

  GameState() {
    reset();
  }

  String pieceAt(int pos) => _pieces[pos];
  String get winner => _winnerPieces == null ? null : _pieces[_winnerPieces[0]];
  bool get gameOver => winner != null || _pieces.every((p) => p != null);
  List<int> get winnerPieces => _winnerPieces;
  String get status => "It's $_player's turn: ${_durationFormatFrom(_started, "HH:MM:SS")}";

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
    assert(_pieces[pos] == null);

    // store the move and check for a winner
    _pieces[pos] = _player;
    for (var win in _wins) {
      if (win.every((p) => _pieces[p] == _player)) {
        _winnerPieces = win;
        break;
      }
    }

    // if the game isn't over, switch players
    if (!gameOver) {
      _player = _player == 'X' ? 'O' : 'X';
    }

    notifyListeners();
  }

  void reset() {
    _pieces.fillRange(0, _pieces.length, null);
    _winnerPieces = null;
    _player = 'X';
    _started = DateTime.now();

    if (_timer != null) _timer.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => notifyListeners());

    notifyListeners();
  }
}

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: ChangeNotifierProvider(
            builder: (_) => GameState(),
            child: GameView(),
          ),
        ),
      ),
    );
  }
}

class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameState>(context);

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: GridPainter(),
            foregroundPainter: WinnerPainter(game),
            child: GamePieces(),
          ),
        ),
        Text(game.status),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const sx = 10.0;
    var paint = Paint()..strokeWidth = sx;
    var dx = (size.width - sx * 2) / 3 + sx / 2;
    var dy = (size.height - sx * 2) / 3 + sx / 2;
    canvas.drawLine(Offset(dx, sx), Offset(dx, size.height - sx), paint);
    canvas.drawLine(Offset(dx * 2 + sx / 2, sx), Offset(dx * 2 + sx / 2, size.height - sx), paint);
    canvas.drawLine(Offset(sx, dy), Offset(size.width - sx, dy), paint);
    canvas.drawLine(Offset(sx, dy * 2 + sx / 2), Offset(size.width - sx, dy * 2 + sx / 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class GamePieces extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(i + 0)])),
          Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(i + 3)])),
          Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(i + 6)])),
        ],
      );
}

class GamePiece extends StatelessWidget {
  final int pos;
  GamePiece(this.pos);

  @override
  Widget build(BuildContext context) => Consumer<GameState>(
        builder: (context, game, child) => Expanded(
              child: CustomPaint(
                painter: PiecePainter(game.pieceAt(pos)),
                child: game.pieceAt(pos) == null
                    ? GestureDetector(
                        onTap: () {
                          if (game.gameOver) return;
                          game.move(pos);
                          if (game.gameOver) gameOver(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(),
                      )
                    : Container(),
              ),
            ),
      );

  void gameOver(BuildContext context) {
    var game = Provider.of<GameState>(context);
    assert(game.gameOver);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(days: 365),
        content: Text(game.winner == null ? "Cat game!" : "${game.winner} is the winner!"),
        action: SnackBarAction(
          label: 'Play Again',
          onPressed: () {
            game.reset();
          },
        ),
      ),
    );
  }
}

class PiecePainter extends CustomPainter {
  final String piece;
  PiecePainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    const sx = 10.0;
    const sx3 = sx * 3;
    var paint = Paint()
      ..strokeWidth = sx
      ..style = PaintingStyle.stroke;

    if (piece == 'X') {
      canvas.drawLine(Offset(sx3, sx3), size.bottomRight(Offset(-sx3, -sx3)), paint);
      canvas.drawLine(size.bottomLeft(Offset(sx3, -sx3)), size.topRight(Offset(-sx3, sx3)), paint);
    } else if (piece == 'O') {
      canvas.drawOval(Rect.fromLTRB(sx3, sx3, size.width - sx3, size.height - sx3), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WinnerPainter extends CustomPainter {
  final GameState game;
  WinnerPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    if (game.winner == null) return;

    const sx = 10.0;
    var paint = Paint()..strokeWidth = sx;
    paint.color = Colors.green;

    canvas.drawLine(_pieceOffset(size, sx, game.winnerPieces[0]),
        _pieceOffset(size, sx, game._winnerPieces[2]), paint);
  }

  Offset _pieceOffset(Size size, double sx, int pos) {
    var dx = (size.width - sx * 2) / 3 + sx / 2;
    var dy = (size.height - sx * 2) / 3 + sx / 2;
    return Offset(pos.remainder(3) * dx + dx / 2, (pos / 3).floor() * dy + dy / 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
