import 'package:flutter/material.dart';

class ChatCentralScreen extends StatefulWidget {
  const ChatCentralScreen({super.key});

  @override
  State<ChatCentralScreen> createState() => _ChatCentralScreenState();
}

class _ChatCentralScreenState extends State<ChatCentralScreen> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusQuickAccess(),
          const SizedBox(height: 24),
          Expanded(child: _buildChatList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(Icons.message_rounded, color: Colors.black),
      ),
    );
  }

  // Acesso rápido aos alunos online/ativos
  Widget _buildStatusQuickAccess() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white10,
                      child: Text(
                        "A$index",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
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
                const Text(
                  "Atleta",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    final chats = [
      {
        "name": "Arthur Fontana",
        "lastMsg": "Treino concluído, coach!",
        "time": "14:05",
        "unread": 2,
        "isPro": true,
      },
      {
        "name": "Turma Elite Sprint",
        "lastMsg": "Nova fórmula disponível no Lab.",
        "time": "13:40",
        "unread": 0,
        "isPro": false,
      },
      {
        "name": "Maria Cobaia",
        "lastMsg": "Pode analisar meu pace de hoje?",
        "time": "10:15",
        "unread": 1,
        "isPro": true,
      },
      {
        "name": "João Henrique",
        "lastMsg": "Valeu pelo feedback!",
        "time": "Ontem",
        "unread": 0,
        "isPro": false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        bool hasUnread = (chat['unread'] as int) > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: hasUnread
                ? const Color(0xFF06B6D4).withOpacity(0.03)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF1A1A1A),
              child: Icon(
                Icons.person_rounded,
                color: chat['isPro'] as bool
                    ? const Color(0xFF06B6D4)
                    : Colors.white24,
              ),
            ),
            title: Row(
              children: [
                Text(
                  chat['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (chat['isPro'] as bool) ...[
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
              chat['lastMsg'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread ? Colors.white70 : Colors.white30,
                fontSize: 12,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'] as String,
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF06B6D4),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${chat['unread']}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // Aqui abriria a conversa específica
            },
          ),
        );
      },
    );
  }
}
