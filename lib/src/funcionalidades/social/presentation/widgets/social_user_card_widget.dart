import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';

class SocialUserCard extends StatelessWidget {
  final UserEntity user;
  final bool isFriend; 
  final VoidCallback? onAddPressed;
  final VoidCallback? onTap;

  const SocialUserCard({
    super.key,
    required this.user,
    this.isFriend = false,
    this.onAddPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, 
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                
                // Info del Usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nombreCompleto.isNotEmpty ? user.nombreCompleto : user.apodo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (user.apodo.isNotEmpty && user.apodo != user.nombreCompleto)
                        Text(
                          "@${user.apodo}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),

              
                if (isFriend)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          l10n.friends,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  IconButton(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    color: Theme.of(context).primaryColor,
                    tooltip: "Añadir a amigos",
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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