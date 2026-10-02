import 'package:latlong2/latlong.dart';

enum TerritoryState { uncaptured, captured, completed, rival, safe }

class TerritoryCell {
  final String id; // "x_y" format
  final int gridX;
  final int gridY;
  final LatLng center;
  final List<LatLng> boundaryPoints;
  final TerritoryState state;

  const TerritoryCell({
    required this.id,
    required this.gridX,
    required this.gridY,
    required this.center,
    required this.boundaryPoints,
    this.state = TerritoryState.captured,
  });

  TerritoryCell copyWith({
    String? id,
    int? gridX,
    int? gridY,
    LatLng? center,
    List<LatLng>? boundaryPoints,
    TerritoryState? state,
  }) {
    return TerritoryCell(
      id: id ?? this.id,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      center: center ?? this.center,
      boundaryPoints: boundaryPoints ?? this.boundaryPoints,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TerritoryCell && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
