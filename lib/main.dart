import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class GameState extends ChangeNotifier {
  List<String> _pieces;
  String _winner;
  String _player;

  GameState() {
    reset();
  }

  String pieceAt(int pos) => _pieces[pos];
  String get winner => _winner;

  static const List<List<int>> _wins = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // by row
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // by column
    [0, 4, 8], [2, 4, 6], // by diagonal
  ];

  void move(int pos) {
    assert(_winner == '');
    assert(_pieces[pos] == '');

    // store the move and check for a winner
    _pieces[pos] = _player;
    _winner = _wins.any((w) => w.every((p) => _pieces[p] == _player)) ? _player : '';
    _player = _player == 'X' ? 'O' : 'X';
    notifyListeners();
  }

  void reset() {
    _pieces = List<String>.filled(9, '');
    _winner = '';
    _player = 'X';

    // test data
    _pieces[2] = 'X';
    _pieces[3] = 'O';
    _pieces[4] = 'X';
    _pieces[5] = 'O';

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

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final pieces = List<String>.filled(9, '');

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: GridPainter(), child: GamePieces(pieces));
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
  final List<String> pieces;
  GamePieces(this.pieces) : assert(pieces.length == 9);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(i + 0)])),
        Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(i + 3)])),
        Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(i + 6)])),
      ],
    );
  }
}

class GamePiece extends StatelessWidget {
  final int pos;
  GamePiece(this.pos);

  @override
  Widget build(BuildContext context) => Consumer<GameState>(
        builder: (context, game, child) => Expanded(
              child: CustomPaint(
                painter: PiecePainter(game.pieceAt(pos)),
                child: game.pieceAt(pos) == ''
                    ? GestureDetector(
                        onTap: () => game.move(pos),
                        behavior: HitTestBehavior.opaque,
                        child: Container(),
                      )
                    : Container(),
              ),
            ),
      );
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
    var origin = Offset(0, 0);

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

/*
show text sized to a specific box
child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              child: Text(piece, style: TextStyle(fontSize: 1000)),
            ),
          ),
*/
