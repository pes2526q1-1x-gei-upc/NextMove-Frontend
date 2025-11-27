import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/utils/create_star_rating_row.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String date;
  final double rating;
  final String comment;
  final Color themeColor;
  final VoidCallback? onEditPressed;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
    required this.themeColor,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          // --- ENCABEZADO ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
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
                    createStarRatingRow((rating * 2).round()),
                  ],
                ),
              ),

            
              if (onEditPressed != null) ...[
                const SizedBox(width: 4),
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_rounded, size: 18, color: themeColor),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(), // Hace el botón compacto
                    onPressed: onEditPressed,
                    tooltip: l10n.editReview,
                  ),
                ),
              ],
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