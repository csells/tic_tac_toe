import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/game_state.dart';
import 'package:tic_tac_toe/mobx_provider_consumer.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, kIsWeb;

void _desktopInitHack() {
  if (kIsWeb) return;

  if (Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  } else if (Platform.isFuchsia) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _desktopInitHack();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _gameState = GameState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Provider(
            value: _gameState,
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
        builder: (context, game) => Expanded(
          child: CustomPaint(
            painter: PiecePainter(game.pieces[pos]),
            child: game.pieces[pos] == null
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
        _pieceOffset(size, sx, game.winnerPieces[2]), paint);
  }

  Offset _pieceOffset(Size size, double sx, int pos) {
    var dx = (size.width - sx * 2) / 3 + sx / 2;
    var dy = (size.height - sx * 2) / 3 + sx / 2;
    return Offset(pos.remainder(3) * dx + dx / 2, (pos / 3).floor() * dy + dy / 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
