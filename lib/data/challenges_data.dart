class ChallengesData {
  static final List<Map<String, dynamic>> allChallenges = [
    {
      "id": "sw_01",
      "icon": "⚔️",
      "theme": "STAR WARS",
      "title": "O Caminho do Jedi",
      "desc": "Complete 42 km em 7 dias",
      "progress": 28.5,
      "total": 42.0,
      "reward": "Badge Mestre Jedi",
      "difficulty": "HARD",
      "isActive": true, // Este aparece na Workouts
    },
    {
      "id": "mv_01",
      "icon": "🦸",
      "theme": "MARVEL",
      "title": "Protocolo Vingador",
      "desc": "Corra 5 dias consecutivos",
      "progress": 3.0,
      "total": 5.0,
      "reward": "Badge Vingador",
      "difficulty": "MEDIUM",
      "isActive": true, // Este aparece na Workouts
    },
    {
      "id": "hp_01",
      "icon": "🪄",
      "theme": "HARRY POTTER",
      "title": "Copa Tribruxo",
      "desc": "Conquiste 10 territórios",
      "progress": 6.0,
      "total": 10.0,
      "reward": "Badge Campeão",
      "difficulty": "MEDIUM",
      "isActive": false, // Este NÃO aparece na Workouts (fica na 'Ver Todos')
    },
  ];
}
