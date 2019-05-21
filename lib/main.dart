import 'package:flutter/material.dart';

class GameBoard extends ChangeNotifier {
  var _pieces = List<String>.filled(9, '');
  String pieceAt(int pos) => _pieces[pos];
  String _winner = '';

  String get winner => _winner;

  void move(int pos, String label) {
    _pieces[pos] = label;
    // check for a winner
    /*
              Cell[,] possibleWins = {
            // row
            { cells[0 + offset], cells[1 + offset], cells[2 + offset] },
            { cells[3 + offset], cells[4 + offset], cells[5 + offset] },
            { cells[6 + offset], cells[7 + offset], cells[8 + offset] },

            // column
            { cells[0 + offset], cells[3 + offset], cells[6 + offset] },
            { cells[1 + offset], cells[4 + offset], cells[7 + offset] },
            { cells[2 + offset], cells[5 + offset], cells[8 + offset] },

            // diagonal
            { cells[0 + offset], cells[4 + offset], cells[8 + offset] },
            { cells[2 + offset], cells[4 + offset], cells[6 + offset] },
          };

    */

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
          child: Game(),
        ),
      ),
    );
  }
}

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
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
    var dx = (size.width - sx * 2) / 3;
    var dy = (size.height - sx * 2) / 3;
    canvas.drawLine(Offset(dx, sx), Offset(dx, size.height - sx), paint);
    canvas.drawLine(Offset(dx * 2, sx), Offset(dx * 2, size.height - sx), paint);
    canvas.drawLine(Offset(sx, dy), Offset(size.width - sx, dy), paint);
    canvas.drawLine(Offset(sx, dy * 2), Offset(size.width - sx, dy * 2), paint);
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
        Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(pieces[i + 0])])),
        Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(pieces[i + 3])])),
        Expanded(child: Row(children: [for (var i = 0; i != 3; ++i) GamePiece(pieces[i + 6])])),
      ],
    );
  }
}

class GamePiece extends StatelessWidget {
  final String label;
  GamePiece(this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    child: Text(label, style: TextStyle(fontSize: 1000)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
