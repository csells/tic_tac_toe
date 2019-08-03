// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$GameState on _GameState, Store {
  final _$playerAtom = Atom(name: '_GameState.player');

  @override
  String get player {
    _$playerAtom.context.enforceReadPolicy(_$playerAtom);
    _$playerAtom.reportObserved();
    return super.player;
  }

  @override
  set player(String value) {
    _$playerAtom.context.conditionallyRunInAction(() {
      super.player = value;
      _$playerAtom.reportChanged();
    }, _$playerAtom, name: '${_$playerAtom.name}_set');
  }

  final _$piecesAtom = Atom(name: '_GameState.pieces');

  @override
  ObservableList<String> get pieces {
    _$piecesAtom.context.enforceReadPolicy(_$piecesAtom);
    _$piecesAtom.reportObserved();
    return super.pieces;
  }

  @override
  set pieces(ObservableList<String> value) {
    _$piecesAtom.context.conditionallyRunInAction(() {
      super.pieces = value;
      _$piecesAtom.reportChanged();
    }, _$piecesAtom, name: '${_$piecesAtom.name}_set');
  }

  final _$winnerPiecesAtom = Atom(name: '_GameState.winnerPieces');

  @override
  List<int> get winnerPieces {
    _$winnerPiecesAtom.context.enforceReadPolicy(_$winnerPiecesAtom);
    _$winnerPiecesAtom.reportObserved();
    return super.winnerPieces;
  }

  @override
  set winnerPieces(List<int> value) {
    _$winnerPiecesAtom.context.conditionallyRunInAction(() {
      super.winnerPieces = value;
      _$winnerPiecesAtom.reportChanged();
    }, _$winnerPiecesAtom, name: '${_$winnerPiecesAtom.name}_set');
  }
}
