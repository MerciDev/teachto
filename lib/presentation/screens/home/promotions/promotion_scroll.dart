import 'dart:async';
import 'package:cenec_app/presentation/screens/home/promotions/basic_promotion.dart';
import 'package:flutter/material.dart';
import 'package:cenec_app/resources/classes/promotion.dart'; // Asegúrate de que esta ruta sea correcta

class PromotionScroll extends StatefulWidget {
  final List<Promotion> promotions;

  const PromotionScroll({super.key, required this.promotions});

  @override
  PromotionScrollState createState() => PromotionScrollState();
}

class PromotionScrollState extends State<PromotionScroll> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 1,
    );
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < calculateTotalPages() - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  double calculateViewportFraction() {
    return widget.promotions.length % 2 == 0 ? 0.8 : 1.0;
  }

  int calculateTotalPages() {
    return (widget.promotions.length / 2).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        itemCount: calculateTotalPages(),
        itemBuilder: (context, pageIndex) {
          int firstPromoIndex = pageIndex * 2;
          int? secondPromoIndex = firstPromoIndex + 1 < widget.promotions.length ? firstPromoIndex + 1 : null;

          return Row(
            children: [
              Expanded(
                child: buildPromotionCard(widget.promotions[firstPromoIndex]),
              ),
              if (secondPromoIndex != null)
                Expanded(
                  child: buildPromotionCard(widget.promotions[secondPromoIndex]),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildPromotionCard(Promotion promotion) {
    final double discountedPrice = promotion.originalPrice * (1 - promotion.discountPercentage / 100);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PromotionDetailPage(promotion: promotion),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: const Color.fromARGB(255, 199, 199, 199),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                      promotion
                          .imagePath, // Asegúrate de que esta sea una URL válida
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        promotion.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${discountedPrice.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
