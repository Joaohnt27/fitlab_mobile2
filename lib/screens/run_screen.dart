import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/summary_sheets.dart';
import '../widgets/countdown_overlay.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> with TickerProviderStateMixin {
  bool isRunning = false;
  bool isPaused = false;
  bool isCountingDown = false;
  int countdownValue = 5;

  int duration = 0;
  double distance = 0.0;
  String pace = "0:00";
  int steps = 0;
  int calories = 0;

  String selectedMode = "Corrida";
  String selectedGoalType = "Distância";
  double targetValue = 3.0;

  LatLng currentPosition = const LatLng(-21.1767, -47.8208);
  List<LatLng> route = [];
  final MapController _mapController = MapController();
  Timer? _timer;

  final List<String> goalOptions = [
    "Distância",
    "Duração",
    "Calorias",
    "Passos",
    "Ganho de Elevação",
    "Sem Metas",
  ];
  final List<String> premiumGoals = ["Calorias", "Passos", "Ganho de Elevação"];
  final List<String> modeOptions = [
    "Corrida",
    "Caminhada",
    "Duelo de Territórios",
  ];

  void _moveCameraToPlayer() {
    double offset = 0.0025;
    LatLng adjustedPosition = LatLng(
      currentPosition.latitude - offset,
      currentPosition.longitude,
    );
    _mapController.move(adjustedPosition, 17.0);
  }

  void _updateGoalValue(String type) {
    setState(() {
      selectedGoalType = type;
      switch (type) {
        case "Distância":
          targetValue = 3.0;
          break;
        case "Duração":
          targetValue = 20.0;
          break;
        case "Calorias":
          targetValue = 200.0;
          break;
        case "Passos":
          targetValue = 1000.0;
          break;
        case "Ganho de Elevação":
          targetValue = 500.0;
          break;
        case "Sem Metas":
          targetValue = 0.0;
          break;
      }
    });
  }

  void _triggerCountdown() {
    setState(() {
      isCountingDown = true;
      countdownValue = 6;
    });

    Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdownValue > 1) {
        setState(() => countdownValue--);
      } else {
        t.cancel();
        setState(() => isCountingDown = false);
        _startRun();
      }
    });
  }

  void _startRun() {
    setState(() {
      isRunning = true;
      isPaused = false;
      if (route.isEmpty) route.add(currentPosition);
    });

    _moveCameraToPlayer();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          duration++;
          double randomLat = (Random().nextDouble() - 0.5) * 0.0008;
          double randomLng = (Random().nextDouble() - 0.5) * 0.0008;

          currentPosition = LatLng(
            currentPosition.latitude + randomLat,
            currentPosition.longitude + randomLng,
          );

          route.add(currentPosition);
          distance += (selectedMode == "Corrida" ? 0.007 : 0.003);
          steps += (Random().nextInt(3) + 1);
          calories = (distance * 65).toInt();

          if (distance > 0) {
            double paceMinutes = (duration / 60) / distance;
            int mins = paceMinutes.floor();
            int secs = ((paceMinutes - mins) * 60).floor();
            pace = "$mins:${secs.toString().padLeft(2, '0')}";
          }

          _moveCameraToPlayer();
        });
      }
    });
  }

  void _stopRun() {
    _timer?.cancel();
    _showSummary((distance * 15).toInt());
  }

  void _showSummary(int xp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SummarySheet(
        route: route,
        distance: distance,
        duration: duration,
        xp: xp,
        pace: pace,
        onClose: () {
          context.read<UserProvider>().ganharXPeVerificarLevelUp(context, xp);
          setState(() {
            isRunning = false;
            isPaused = false;
            duration = 0;
            distance = 0;
            route = [];
            steps = 0;
            calories = 0;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition,
              initialZoom: 16.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.fitlab.app',
              ),
              if (route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route,
                      color: const Color(0xFF06B6D4),
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    width: 70,
                    height: 70,
                    child: _buildPlayerMarker(),
                  ),
                ],
              ),
            ],
          ),

          // 2. PAINEL INFERIOR
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D0D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isRunning ? _buildRunningHUD() : _buildSetupUI(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          if (isCountingDown) CountdownOverlay(value: countdownValue),
        ],
      ),
    );
  }

  Widget _buildSetupUI() {
    return Column(
      children: [
        Text(
          "META: ${selectedGoalType.toUpperCase()}",
          style: const TextStyle(
            color: Color(0xFF06B6D4),
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),
        if (selectedGoalType == "Sem Metas")
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Treino Livre",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleButton(
                Icons.remove,
                () => setState(() => targetValue > 1 ? targetValue-- : null),
              ),
              const SizedBox(width: 30),
              Column(
                children: [
                  Text(
                    "${targetValue.toInt()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getUnitLabel().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              _buildCircleButton(
                Icons.add,
                () => setState(() => targetValue++),
              ),
            ],
          ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _showSelectionMenu("Modalidade", modeOptions),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getModeIcon(), color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                selectedMode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
                size: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            _buildSmallActionBtn(
              Icons.flag,
              () => _showSelectionMenu("Meta", goalOptions),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GestureDetector(
                onTap: _triggerCountdown,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      "INICIAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            _buildSmallActionBtn(
              Icons.tune,
              () => _showSelectionMenu("Modalidade", modeOptions),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunningHUD() {
    double progress = targetValue > 0 ? (distance / targetValue) : 0.0;
    if (selectedGoalType == "Duração")
      progress = (duration / (targetValue * 60));

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: selectedGoalType == "Sem Metas"
                    ? null
                    : progress.clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF06B6D4),
                ),
              ),
            ),
            Column(
              children: [
                const Text(
                  "CORRENDO",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  selectedGoalType == "Sem Metas"
                      ? "Livre"
                      : "${(progress * 100).toInt().clamp(0, 100)}%", 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedGoalType != "Sem Metas")
                  Text(
                    "de ${targetValue.toInt()} ${_getUnitLabel()}",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              Icons.timer_outlined,
              _formatTime(duration),
              "Duração",
              const Color(0xFF06B6D4),
            ),
            _statItem(
              Icons.location_on_outlined,
              distance.toStringAsFixed(2),
              "km",
              Colors.white,
            ),
            _statItem(Icons.speed_outlined, pace, "min/km", Colors.greenAccent),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              Icons.local_fire_department_outlined,
              "$calories",
              "Calorias",
              Colors.orangeAccent,
            ),
            _statItem(
              Icons.directions_walk,
              "$steps",
              "Passos",
              Colors.white70,
            ),
            _statItem(Icons.favorite_border, "95", "bpm", Colors.redAccent),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            if (isPaused) ...[
              Expanded(
                child: _buildHUDButton("PARAR", Colors.redAccent, _stopRun),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHUDButton(
                  "CONTINUAR",
                  const Color(0xFF06B6D4),
                  () => setState(() => isPaused = false),
                ),
              ),
            ] else
              Expanded(
                child: _buildHUDButton(
                  "PAUSAR",
                  Colors.white.withOpacity(0.05),
                  () => setState(() => isPaused = true),
                  hasBorder: true,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _getUnitLabel() {
    switch (selectedGoalType) {
      case "Distância":
        return "km";
      case "Duração":
        return "min";
      case "Calorias":
        return "cal";
      case "Passos":
        return "passos";
      case "Ganho de Elevação":
        return "m";
      default:
        return "";
    }
  }

  Widget _buildPlayerMarker() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF06B6D4), width: 3),
      ),
      child: const Icon(Icons.navigation, color: Color(0xFF06B6D4), size: 30),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHUDButton(
    String label,
    Color color,
    VoidCallback onTap, {
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: hasBorder
              ? Border.all(color: const Color(0xFF06B6D4), width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getModeIcon() {
    if (selectedMode == "Caminhada") return Icons.directions_walk;
    if (selectedMode == "Duelo de Territórios") return Icons.sports_mma;
    return Icons.directions_run;
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildSmallActionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void _showSelectionMenu(String title, List<String> options) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) {
              bool isPremium = premiumGoals.contains(opt);
              return ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    color: isPremium ? Colors.amber : Colors.white,
                  ),
                ),
                trailing: isPremium
                    ? const Icon(Icons.star, color: Colors.amber, size: 16)
                    : null,
                onTap: () {
                  if (title == "Meta")
                    _updateGoalValue(opt);
                  else
                    setState(() => selectedMode = opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
