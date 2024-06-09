import 'package:flutter/material.dart';
import 'package:cenec_app/presentation/screens/home/promotions/promotion_scroll.dart';
import 'package:cenec_app/resources/classes/promotion.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promociones de Cursos',
            style: Theme.of(context).textTheme.displayMedium),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Promotion>>(
          future: Promotion.getPromotions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<Promotion> promotions = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(context, 'Ofertas destacadas', [
                  _buildPromotionScroll(promotions, "upOffers"),
                ]),
                const SizedBox(height: 20),
                _buildSection(context, 'Cursos destacados', [
                  _buildPromotionScroll(promotions, "upCourses"),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.displaySmall!,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildPromotionScroll(List<Promotion> promotions, String tag) {
    List<Promotion> newPromotions = [];
    for (Promotion promotion in promotions) {
      if (promotion.tags.contains(tag)) newPromotions.add(promotion);
    }
    return PromotionScroll(
      promotions: newPromotions,
    );
  }
}
