import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import 'chat_room_screen.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatCentralScreen extends StatefulWidget {
  const ChatCentralScreen({super.key});

  @override
  State<ChatCentralScreen> createState() => _ChatCentralScreenState();
}

class _ChatCentralScreenState extends State<ChatCentralScreen> {
  List<dynamic> _contatos = [];
  bool _isLoading = true;
  StompClient? _stompClient;

  @override
  void initState() {
    super.initState();
    _carregarContatos();
    _conectarWebSocketGlobal();
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    super.dispose();
  }

  Future<void> _carregarContatos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.usuarioLogado;
    if (usuario == null) return;

    final isTreinador = usuario.role == 'Treinador';

    try {
      if (isTreinador) {
        final url = Uri.parse(
          '${ApiConstants.baseUrl}/mentorias/treinador/${usuario.id}/alunos',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> alunos = json.decode(
            utf8.decode(response.bodyBytes),
          );
          setState(() {
            _contatos = alunos
                .map(
                  (a) => {
                    "idAlvo": a['idAtleta'],
                    "nome": a['nome'],
                    "avatar": a['avatar'] ?? "🏃‍♂️",
                    "subtitle": a['plano'] ?? "Aluno",
                    "isPro": (a['plano'] ?? "")
                        .toString()
                        .toUpperCase()
                        .contains('ELITE'),
                    // 👇 PREPARANDO OS CAMPOS DE MENSAGEM 👇
                    "unread": a['mensagensNaoLidas'] ?? 0,
                    "lastMsg":
                        a['ultimaMensagem'] ?? "Toque para abrir a conversa...",
                    "time": a['horaUltimaMensagem'] ?? "",
                  },
                )
                .toList();
          });
        }
      } else {
        final url = Uri.parse(
          '${ApiConstants.baseUrl}/mentorias/atleta/${usuario.id}/ativa',
        );
        final response = await http.get(url);

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final mentoria = json.decode(utf8.decode(response.bodyBytes));
          setState(() {
            _contatos = [
              {
                "idAlvo": mentoria['treinadorId'] ?? mentoria['treinador_id'],
                "nome":
                    mentoria['treinadorNome'] ??
                    mentoria['treinador_nome'] ??
                    "Treinador",
                "avatar": "👨‍🏫",
                "subtitle": "Treinador Oficial",
                "isPro": true,
                // 👇 PREPARANDO OS CAMPOS DE MENSAGEM 👇
                "unread": mentoria['mensagensNaoLidas'] ?? 0,
                "lastMsg":
                    mentoria['ultimaMensagem'] ??
                    "Envie uma mensagem para seu coach!",
                "time": mentoria['horaUltimaMensagem'] ?? "",
              },
            ];
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar contatos de chat: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 👇 NOVO MÉTODO PARA ESCUTAR MENSAGENS EM TEMPO REAL NA CENTRAL 👇
  void _conectarWebSocketGlobal() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final meuId = userProvider.usuarioLogado?.id;
    if (meuId == null) return;

    String baseWs = ApiConstants.baseUrl
        .replaceAll('http://', 'ws://')
        .replaceAll('https://', 'wss://');

    if (baseWs.endsWith('/')) {
      baseWs = baseWs.substring(0, baseWs.length - 1);
    }

    final wsUrl = '$baseWs/ws';

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          // Se inscreve no SEU canal pessoal
          _stompClient!.subscribe(
            destination: '/user/$meuId/queue/mensagens',
            callback: (StompFrame frame) {
              // Quando bater QUALQUER mensagem aqui, nós simplesmente pedimos pro Java
              // recarregar a lista. Assim a bolinha azul acende e o texto atualiza na hora!
              _carregarContatos();
            },
          );
        },
        onWebSocketError: (dynamic error) =>
            debugPrint("Erro WS Central: $error"),
      ),
    );
    _stompClient!.activate();
  }

  void _abrirChat(Map<String, dynamic> contato) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          idDestinatario: contato['idAlvo'],
          nomeDestinatario: contato['nome'],
          avatarDestinatario: contato['avatar'],
        ),
      ),
    );
    _carregarContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CENTRAL DE COMUNICAÇÃO",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            )
          : Column(
              children: [
                if (_contatos.isNotEmpty) _buildStatusQuickAccess(),
                if (_contatos.isNotEmpty) const SizedBox(height: 24),
                Expanded(child: _buildChatList()),
              ],
            ),
    );
  }

  Widget _buildStatusQuickAccess() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: _contatos.length,
        itemBuilder: (context, index) {
          final c = _contatos[index];
          return GestureDetector(
            onTap: () => _abrirChat(c),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white10,
                        child: Text(
                          c['avatar'] ?? "🏃‍♂️",
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent, // Fica online!
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0D0D0D),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (c['nome'] as String)
                        .split(' ')
                        .first, // Só o primeiro nome
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    if (_contatos.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum contato disponível para chat no momento.",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _contatos.length,
      itemBuilder: (context, index) {
        final contato = _contatos[index];
        // 👇 LÓGICA DE NOTIFICAÇÃO 👇
        final bool hasUnread = (contato['unread'] as int? ?? 0) > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            // A cor foi removida daqui! Deixamos apenas as bordas e o arredondamento.
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasUnread
                  ? const Color(0xFF06B6D4).withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          clipBehavior: Clip
              .antiAlias, // 👈 Garante que o clique não vaze pelas bordas arredondadas
          child: Material(
            // 👇 A cor dinâmica agora fica no Material, garantindo a animação do clique!
            color: hasUnread
                ? const Color(0xFF06B6D4).withOpacity(0.05)
                : Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF1A1A1A),
                child: Text(
                  contato['avatar'],
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      contato['nome'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: hasUnread
                            ? FontWeight.w900
                            : FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (contato['isPro'] == true) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF06B6D4),
                      size: 14,
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                contato['lastMsg'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasUnread ? Colors.white : Colors.white38,
                  fontSize: 12,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (contato['time'].toString().isNotEmpty)
                    Text(
                      contato['time'],
                      style: TextStyle(
                        color: hasUnread
                            ? const Color(0xFF06B6D4)
                            : Colors.white24,
                        fontSize: 10,
                        fontWeight: hasUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  if (hasUnread) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF06B6D4),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${contato['unread']}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.chevron_right, color: Colors.white24),
                  ],
                ],
              ),
              onTap: () => _abrirChat(contato),
            ),
          ),
        );
      },
    );
  }
}
