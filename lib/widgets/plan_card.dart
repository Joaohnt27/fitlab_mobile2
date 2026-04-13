import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final Color accentColor;
  final bool isRecommended;
  final bool isCurrentPlan;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    required this.accentColor,
    required this.onTap,
    this.isRecommended = false,
    this.isCurrentPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isCurrentPlan
              ? accentColor.withOpacity(0.5)
              : (isRecommended ? accentColor : Colors.white.withOpacity(0.05)),
          width: 2,
        ),
        boxShadow: (isRecommended || isCurrentPlan)
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: isCurrentPlan ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildPrice(),
                const Divider(height: 40, color: Colors.white10),
                ...features.map((f) => _buildFeatureItem(f)),
                const SizedBox(height: 24),
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isCurrentPlan ? Colors.white : accentColor,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        if (isCurrentPlan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              "PLANO ATUAL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (isRecommended)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "RECOMENDADO",
              style: TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrice() {
    return Opacity(
      opacity: isCurrentPlan ? 0.5 : 1.0,
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            "/mês",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: isCurrentPlan ? Colors.white24 : accentColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: isCurrentPlan ? Colors.white38 : Colors.white70,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentPlan
              ? Colors.transparent
              : (isRecommended ? accentColor : Colors.white.withOpacity(0.05)),
          foregroundColor: isCurrentPlan
              ? Colors.redAccent
              : (isRecommended ? Colors.black : Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isCurrentPlan
                ? const BorderSide(color: Colors.redAccent, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Text(
          isCurrentPlan
              ? "CANCELAR ASSINATURA"
              : (isRecommended ? "ASSINAR AGORA" : "ASSINAR"),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
