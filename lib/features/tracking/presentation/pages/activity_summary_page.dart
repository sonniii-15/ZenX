import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../../../../core/widgets/zenx_stat_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../territory/domain/models/territory_cell.dart';

class ActivitySummaryPage extends ConsumerStatefulWidget {
  final Duration duration;
  final double distanceKm;
  final List<LatLng> routeCoordinates;
  final int gpsPointCount;
  final int capturedCellsCount;
  final List<TerritoryCell> capturedCells;
  final double territoryAreaSqKm;
  final bool isLoopCompleted;
  final int earnedPoints;
  final double averageSpeedKmh;
  final double estimatedCalories;

  const ActivitySummaryPage({
    super.key,
    required this.duration,
    required this.distanceKm,
    required this.routeCoordinates,
    required this.gpsPointCount,
    this.capturedCellsCount = 0,
    this.capturedCells = const [],
    this.territoryAreaSqKm = 0.0,
    this.isLoopCompleted = false,
    this.earnedPoints = 0,
    this.averageSpeedKmh = 0.0,
    this.estimatedCalories = 0.0,
  });

  @override
  ConsumerState<ActivitySummaryPage> createState() => _ActivitySummaryPageState();
}

class _ActivitySummaryPageState extends ConsumerState<ActivitySummaryPage> {

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _shareActivity() {
    context.push(
      '/create-post',
      extra: {
        'duration': widget.duration,
        'distanceKm': widget.distanceKm,
        'routeCoordinates': widget.routeCoordinates,
        'gpsPointCount': widget.gpsPointCount,
        'capturedCellsCount': widget.capturedCellsCount,
        'territoryAreaSqKm': widget.territoryAreaSqKm,
        'isLoopCompleted': widget.isLoopCompleted,
        'earnedPoints': widget.earnedPoints,
        'averageSpeedKmh': widget.averageSpeedKmh,
        'estimatedCalories': widget.estimatedCalories,
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ACTIVITY SUMMARY',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Map Route Summary Preview
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ZenXColors.primary.withValues(alpha: 0.3)),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.routeCoordinates.isEmpty
                  ? const Center(child: Text('No Route Data'))
                  : FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.coordinates(
                          coordinates: widget.routeCoordinates,
                          padding: const EdgeInsets.all(24.0),
                        ),
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                        ),
                        if (widget.capturedCells.isNotEmpty)
                          PolygonLayer(
                            polygons: widget.capturedCells.map((cell) {
                              return Polygon(
                                points: cell.boundaryPoints,
                                color: widget.isLoopCompleted 
                                    ? ZenXColors.primary.withValues(alpha: 0.4) 
                                    : ZenXColors.error.withValues(alpha: 0.25),
                                borderColor: widget.isLoopCompleted
                                    ? ZenXColors.primary
                                    : ZenXColors.error,
                                borderStrokeWidth: 2.0,
                              );
                            }).toList(),
                          ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: widget.routeCoordinates,
                              strokeWidth: 4.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),

          // Summary Stats Grid
          Expanded(
            flex: 6,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AnimateList(
                interval: 100.ms,
                effects: [const FadeEffect(duration: Duration(milliseconds: 300)), const SlideEffect(begin: Offset(0, 0.1), duration: Duration(milliseconds: 300))],
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ZenXStatCard(
                          title: 'Duration',
                          value: _formatDuration(widget.duration),
                          icon: Icons.timer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ZenXStatCard(
                          title: 'Distance',
                          value: '${widget.distanceKm.toStringAsFixed(2)} km',
                          icon: Icons.directions_run,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ZenXStatCard(
                          title: 'Territory',
                          value: '${widget.capturedCellsCount} cells',
                          icon: Icons.grid_on,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ZenXStatCard(
                          title: 'Points',
                          value: '${widget.earnedPoints} pts',
                          icon: Icons.stars,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ZenXStatCard(
                          title: 'Avg Speed',
                          value: '${widget.averageSpeedKmh.toStringAsFixed(1)} km/h',
                          icon: Icons.speed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ZenXStatCard(
                          title: 'Calories',
                          value: '${widget.estimatedCalories.toStringAsFixed(0)} kcal',
                          icon: Icons.local_fire_department,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Share Section
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('SKIP'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _shareActivity,
                          child: const Text('SHARE AS POST', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
