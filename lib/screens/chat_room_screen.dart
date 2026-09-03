import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class ChatRoomScreen extends StatefulWidget {
  final int idDestinatario;
  final String nomeDestinatario;
  final String avatarDestinatario;

  const ChatRoomScreen({
    super.key,
    required this.idDestinatario,
    required this.nomeDestinatario,
    required this.avatarDestinatario,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _mensagens = [];
  bool _isLoadingHistorico = true;
  StompClient? _stompClient;
  late int _meuId;

  @override
  void initState() {
    super.initState();
    _meuId =
        Provider.of<UserProvider>(context, listen: false).usuarioLogado?.id ??
        0;
    _carregarHistorico();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _stompClient?.deactivate(); // Desconecta do Java ao sair da tela
    super.dispose();
  }

  // 1. CARREGA O HISTÓRICO VIA HTTP NORMAL
  Future<void> _carregarHistorico() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/chat/historico/$_meuId/${widget.idDestinatario}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _mensagens = json.decode(utf8.decode(response.bodyBytes));
          _isLoadingHistorico = false;
        });
        _conectarWebSocket(); // Conecta só depois de carregar o passado
        _rolarParaFim();
      }
    } catch (e) {
      debugPrint("Erro ao carregar histórico: $e");
      setState(() => _isLoadingHistorico = false);
    }
  }

  // 2. CONECTA O TÚNEL WEBSOCKET (STOMP) AO SPRING BOOT
  void _conectarWebSocket() {
    // Transforma http://... para ws://... e previne barras duplas "//"
    String baseWs = ApiConstants.baseUrl
        .replaceAll('http://', 'ws://')
        .replaceAll('https://', 'wss://');

    // Remove a barra final se existir antes de adicionar o /ws
    if (baseWs.endsWith('/')) {
      baseWs = baseWs.substring(0, baseWs.length - 1);
    }

    final wsUrl = '$baseWs/ws';
    debugPrint("Tentando conectar no WebSocket: $wsUrl");

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) =>
            debugPrint("Erro de WebSocket: $error"),
        onStompError: (dynamic error) => debugPrint("Erro de STOMP: $error"),
        onDisconnect: (dynamic frame) =>
            debugPrint("Desconectado do WebSocket."),
      ),
    );
    _stompClient!.activate();
  }

  // 3. O QUE ACONTECE QUANDO O TÚNEL ABRE
  void _onConnect(StompFrame frame) {
    debugPrint("✅ Conectado ao Chat em Tempo Real!");

    // Inscreve o app no canal específico deste usuário
    _stompClient!.subscribe(
      destination: '/user/$_meuId/queue/mensagens',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final novaMensagem = json.decode(frame.body!);

          // Se a mensagem for de quem estamos conversando, joga na tela!
          if (novaMensagem['remetenteId'] == widget.idDestinatario) {
            setState(() {
              _mensagens.add(novaMensagem);
            });
            _rolarParaFim();
          }
        }
      },
    );
  }

  // 4. ENVIA MENSAGEM DO FLUTTER PARA O JAVA
  void _enviarMensagem() {
    final texto = _msgController.text.trim();
    if (texto.isEmpty || _stompClient == null || !_stompClient!.isActive)
      return;

    final msgParaEnviar = {
      "remetenteId": _meuId,
      "destinatarioId": widget.idDestinatario,
      "conteudo": texto,
    };

    // Manda pelo túnel
    _stompClient!.send(
      destination: '/app/chat',
      body: json.encode(msgParaEnviar),
    );

    // Otimismo: Mostra na tela na hora, sem esperar o Java confirmar
    setState(() {
      _mensagens.add(msgParaEnviar);
    });

    _msgController.clear();
    _rolarParaFim();
  }

  void _rolarParaFim() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white10,
              child: Text(
                widget.avatarDestinatario,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.nomeDestinatario,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingHistorico
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, index) {
                      final msg = _mensagens[index];
                      final bool isMinha = msg['remetenteId'] == _meuId;

                      return Align(
                        alignment: isMinha
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMinha
                                ? const Color(0xFF06B6D4)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMinha
                                  ? const Radius.circular(16)
                                  : const Radius.circular(4),
                              bottomRight: isMinha
                                  ? const Radius.circular(4)
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            msg['conteudo'],
                            style: TextStyle(
                              color: isMinha ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: isMinha
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Digite uma mensagem...",
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _enviarMensagem(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _enviarMensagem,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF06B6D4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
