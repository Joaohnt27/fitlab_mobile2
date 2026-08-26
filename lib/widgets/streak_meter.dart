import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class StreakMeter extends StatelessWidget {
  const StreakMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Medidor de sequência",
      triggerMode: TooltipTriggerMode.tap,
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final streak = userProvider.usuarioLogado?.streak ?? 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: streak > 0
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: streak > 0 ? Colors.orange : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  "$streak",
                  style: TextStyle(
                    color: streak > 0 ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
