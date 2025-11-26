import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String date;
  final int rating;
  final String comment;
  final Color themeColor;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ENCABEZADO: Avatar + Info + Estrellas ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar con inicial
              CircleAvatar(
                backgroundColor: themeColor.withOpacity(0.1),
                radius: 18,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Nombre y Fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Estrellas 
              Transform.scale(
                scale: 0.8, 
                alignment: Alignment.centerRight, 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    createStarRatingRow(rating.round()),
                  ],
                ),
              ),
            ],
          ),
          
          // --- COMENTARIO ---
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}