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
  final String? userPhotoUrl; 

  const ReviewCard({
    super.key,
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
    required this.themeColor,
    this.onEditPressed,
    this.userPhotoUrl, 
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto = userPhotoUrl != null && userPhotoUrl!.isNotEmpty;

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 
              theme.brightness == Brightness.dark ? 0.35 : 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- AVATAR CON LOGICA DE FOTO ---
              CircleAvatar(
                backgroundColor: themeColor.withValues(alpha: 0.15),
                radius: 18,
                backgroundImage: hasPhoto ? NetworkImage(userPhotoUrl!) : null,
                child: !hasPhoto
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Nombre y Fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

              // Botón de editar
              if (onEditPressed != null) ...[
                const SizedBox(width: 4),
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 
                      theme.brightness == Brightness.dark ? 0.4 : 0.9,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_rounded, size: 18, color: themeColor),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: onEditPressed,
                    tooltip: l10n.editReview,
                  ),
                ),
              ],
            ],
          ),

          // Comentario
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: theme.textTheme.bodyMedium?.copyWith(
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