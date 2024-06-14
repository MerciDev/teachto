import 'package:cenec_app/resources/classes/promotion.dart';
import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback onTap;

  const PromotionCard(
      {super.key, required this.promotion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                color: const Color.fromARGB(255, 199, 199, 199),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de la promoción
                    Image.network(
                      promotion
                          .imagePath, // Asegúrate de que esta sea una URL válida
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 8),
                    // Título de la promoción
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
                    const SizedBox(height: 4),
                    // Descripción de la promoción con corte automático
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width:
                            double.infinity, // Ancho máximo para la descripción
                        child: Text(
                          promotion.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
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
                  child: Column(
                    children: [
                      Text(
                        '${promotion.originalPrice.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${promotion.discountedPrice.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
