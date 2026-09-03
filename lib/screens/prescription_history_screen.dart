import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class PrescriptionHistoryScreen extends StatefulWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  State<PrescriptionHistoryScreen> createState() =>
      _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  int _filterIndex = 0; // 0 = Todos, 1 = Individual, 2 = Turma
  List<dynamic> _historico = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarHistorico();
  }

  Future<void> _buscarHistorico() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;
    if (idTreinador == null) return;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/treinos/treinador/$idTreinador/historico',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _historico = json.decode(utf8.decode(response.bodyBytes));
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar histórico: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "HISTÓRICO DE FÓRMULAS",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            )
          : RefreshIndicator(
              onRefresh: _buscarHistorico,
              color: const Color(0xFF06B6D4),
              backgroundColor: const Color(0xFF1A1A1A),
              child: Column(
                children: [
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildHistoryList()),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _filterChip(0, "TODOS"),
          _filterChip(1, "INDIVIDUAL"),
          _filterChip(2, "TURMAS"),
        ],
      ),
    );
  }

  Widget _filterChip(int index, String label) {
    bool isSelected = _filterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (val) => setState(() => _filterIndex = index),
        selectedColor: const Color(0xFF06B6D4),
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.white10,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Aplica o filtro localmente
    List<dynamic> listFiltrada = _historico.where((item) {
      if (_filterIndex == 1) return item['tipoAlvo'] == "INDIVIDUAL";
      if (_filterIndex == 2) return item['tipoAlvo'] == "TURMA";
      return true;
    }).toList();

    if (listFiltrada.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum histórico encontrado.",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: listFiltrada.length,
      itemBuilder: (context, index) {
        final item = listFiltrada[index];

        final isRecusado = item['status'] == "RECUSADO";
        final isAceito = item['status'] == "ACEITO";

        // Cores baseadas no status
        Color cardColor = const Color(0xFF1A1A1A);
        Color borderColor = Colors.white.withOpacity(0.05);
        if (isRecusado) {
          cardColor = Colors.redAccent.withOpacity(0.05);
          borderColor = Colors.redAccent.withOpacity(0.3);
        } else if (isAceito) {
          cardColor = Colors.green.withOpacity(0.05);
          borderColor = Colors.green.withOpacity(0.3);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item['titulo'] ?? "Treino",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "Para: ${item['nomeAlvo']}",
                  style: const TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['data'] ?? "",
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (isRecusado && item['motivo'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Motivo: ${item['motivo']}",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAceito
                        ? Colors.green
                        : isRecusado
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'] ?? "PENDENTE",
                    style: TextStyle(
                      color: isAceito || isRecusado
                          ? Colors.white
                          : Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['tipoAlvo'] ?? "INDIVIDUAL",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
