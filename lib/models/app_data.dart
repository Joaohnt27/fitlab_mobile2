import 'package:flutter/material.dart';

class AppData {
  // avisa aos widgets quando o dado muda
  static ValueNotifier<Map<String, dynamic>?> experimentoAtivo = ValueNotifier(
    null,
  );

  static void salvarExperimento(String volume, String frequencia) {
    experimentoAtivo.value = {
      'volume': volume,
      'frequencia': frequencia,
      'progresso': 0.3,
      'diasRestantes': 7,
    };
  }
}
