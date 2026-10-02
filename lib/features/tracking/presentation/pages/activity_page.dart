import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../providers/tracking_provider.dart';
import '../../../gamification/presentation/providers/user_profile_provider.dart';
import '../../../gamification/domain/engine/gamification_engine.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../social/domain/models/social_post.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../territory/domain/models/territory_cell.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  final MapController _mapController = MapController();

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _recenter(LatLng? loc) {
    if (loc != null) {
      _mapController.move(loc, 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingProvider);

    ref.listen(trackingProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: ZenXColors.error,
          ),
        );
      }
      // Auto follow camera if tracking and location changes
      if (next.isTracking && next.currentLocation != null && previous?.currentLocation != next.currentLocation) {
        _mapController.move(next.currentLocation!, _mapController.camera.zoom);
      }
    });

    final allTerritories = [...trackingState.capturedTerritory, ...trackingState.mockTerritory];

    return Scaffold(
      backgroundColor: Colors.white, // Bright map background
      body: Stack(
        children: [
          // 1. Map Layer
          Positioned.fill(
            child: trackingState.currentLocation == null
                ? const Center(child: CircularProgressIndicator(color: ZenXColors.primary))
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: trackingState.currentLocation!,
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      // Bright OSM Tiles
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.zenx.app',
                      ),
                      
                      // Territory Layer
                      if (allTerritories.isNotEmpty)
                        PolygonLayer(
                          polygons: allTerritories.map((cell) {
                            Color fillColor;
                            Color borderColor;
                            
                            switch (cell.state) {
                              case TerritoryState.captured:
                              case TerritoryState.completed:
                                fillColor = ZenXColors.error.withValues(alpha: 0.3);
                                borderColor = ZenXColors.error;
                                break;
                              case TerritoryState.rival:
                                fillColor = Colors.blue.withValues(alpha: 0.3);
                                borderColor = Colors.blue;
                                break;
                              case TerritoryState.safe:
                                fillColor = Colors.green.withValues(alpha: 0.3);
                                borderColor = Colors.green;
                                break;
                              default:
                                fillColor = Colors.transparent;
                                borderColor = Colors.transparent;
                            }
                            
                            return Polygon(
                              points: cell.boundaryPoints,
                              color: fillColor,
                              borderColor: borderColor,
                              borderStrokeWidth: 2.0,
                            );
                          }).toList(),
                        ),
                        
                      // Route Layer
                      if (trackingState.routeCoordinates.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: trackingState.routeCoordinates,
                              strokeWidth: 5.0,
                              color: ZenXColors.error,
                            ),
                          ],
                        ),
                        
                      // Location Marker Layer
                      MarkerLayer(
                        markers: [
                          if (trackingState.currentLocation != null)
                            Marker(
                              point: trackingState.currentLocation!,
                              width: 60,
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Accuracy Halo
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  // Center Dot
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withValues(alpha: 0.5),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),

          // 2. Top UI: GPS Pill
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_cellular_alt, color: Colors.green[600], size: 16),
                  const SizedBox(width: 4),
                  const Text('GPS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: Colors.green[500], shape: BoxShape.circle),
                  )
                ],
              ),
            ),
          ),

          // 3. Top UI: Black Stats Card
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn(_formatDuration(trackingState.elapsedDuration), 'TIME'),
                  _buildStatColumn(trackingState.distanceInKm.toStringAsFixed(2), 'DISTANCE (KM)'),
                  _buildStatColumn(
                    trackingState.currentSpeedMps <= 0.28 
                        ? '--\'--"' 
                        : (trackingState.averageSpeedKmh > 0 
                            ? '${(60 / trackingState.averageSpeedKmh).floor()}\'${((60 / trackingState.averageSpeedKmh).remainder(1) * 60).toInt().toString().padLeft(2, '0')}"'
                            : '--\'--"'),
                    'PACE (MIN/KM)',
                  ),
                  _buildStatColumn(trackingState.estimatedCalories.toStringAsFixed(0), 'CAL'),
                ],
              ),
            ),
          ),

          // 4. Right Map Controls
          Positioned(
            bottom: 150,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControlButton(Icons.my_location, () => _recenter(trackingState.currentLocation)),
                const SizedBox(height: 12),
                _buildMapControlButton(Icons.add, _zoomIn),
                const SizedBox(height: 12),
                _buildMapControlButton(Icons.remove, _zoomOut),
              ],
            ),
          ),

          // 5. Bottom Activity Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    final notifier = ref.read(trackingProvider.notifier);
                    if (trackingState.isTracking) {
                      final finalDuration = trackingState.elapsedDuration;
                      final finalDistanceKm = trackingState.distanceInKm;
                      final finalRoute = List<LatLng>.from(trackingState.routeCoordinates);
                      final finalGpsCount = trackingState.gpsPointCount;

                      notifier.stopTracking();

                      if (finalDistanceKm < 0.05) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Activity too short to record. Minimum 50m required.'),
                            backgroundColor: ZenXColors.error,
                          ),
                        );
                        notifier.resetTracking();
                        return;
                      }

                      await ref.read(userProfileProvider.notifier).processCompletedActivity(trackingState);
                      int earnedPoints = (trackingState.capturedTerritory.length * GamificationEngine.pointsPerCell) + 
                                         (trackingState.distanceInKm * GamificationEngine.pointsPerKm).toInt();
                      if (trackingState.isLoopCompleted) {
                        earnedPoints += GamificationEngine.pointsForLoop;
                      }
                      
                      final authUser = ref.read(authStateProvider).valueOrNull;
                      final userProfile = ref.read(userProfileProvider).valueOrNull;
                      if (authUser != null && userProfile != null) {
                        final post = SocialPost(
                          id: '',
                          userId: authUser.uid,
                          username: userProfile.username,
                          profileImageUrl: null,
                          caption: 'Completed an activity!',
                          distanceKm: finalDistanceKm,
                          duration: finalDuration,
                          points: earnedPoints,
                          capturedCellsCount: trackingState.capturedTerritory.length,
                          createdAt: DateTime.now(),
                          routeCoordinates: finalRoute,
                        );
                        await ref.read(socialRepositoryProvider).createPost(post);
                      }

                      if (!context.mounted) return;

                      context.push(
                        '/activity-summary',
                        extra: {
                          'duration': finalDuration,
                          'distanceKm': finalDistanceKm,
                          'routeCoordinates': finalRoute,
                          'gpsPointCount': finalGpsCount,
                          'capturedCellsCount': trackingState.capturedTerritory.length,
                          'capturedCells': trackingState.capturedTerritory,
                          'territoryAreaSqKm': trackingState.territoryAreaSqKm,
                          'isLoopCompleted': trackingState.isLoopCompleted,
                          'earnedPoints': earnedPoints,
                          'averageSpeedKmh': trackingState.averageSpeedKmh,
                          'estimatedCalories': trackingState.estimatedCalories,
                        },
                      );
                    } else {
                      await notifier.startTracking();
                    }
                  },
                  child: Container(
                    height: 65,
                    width: 220,
                    decoration: BoxDecoration(
                      color: ZenXColors.error, // Red pill button
                      borderRadius: BorderRadius.circular(32.5),
                      boxShadow: [
                        BoxShadow(
                          color: ZenXColors.error.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        trackingState.isTracking ? 'STOP' : 'CAPTURE',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ).animate(onPlay: (controller) => trackingState.isTracking ? controller.repeat(reverse: true) : controller.stop())
                   .scaleXY(begin: 1.0, end: 1.02, duration: 1000.ms, curve: Curves.easeInOut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.white54, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

}
