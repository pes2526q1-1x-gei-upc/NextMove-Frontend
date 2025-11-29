import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/profile_info_row_widget.dart';

class FriendDetailsContent extends StatelessWidget {
  final UserEntity user;

  const FriendDetailsContent({super.key, required this.user});

  // Helper para normalizar el modo de transporte
  bool _isBike(String mode) {
    final m = mode.toUpperCase();
    return m == 'BIKE' || m == 'BICICLETA' || m == 'BICI';
  }

  @override
  Widget build(BuildContext context) {
  
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto = user.photo.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          
          // --- AVATAR Y NOMBRE ---
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    color: Colors.grey[200],
                    image: hasPhoto 
                        ? DecorationImage(
                            image: NetworkImage(user.photo),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                               debugPrint("Error cargando foto detalle: $exception");
                            },
                          )
                        : null,
                  ),
                  // Si no hay foto o falla, mostramos el icono
                  child: !hasPhoto 
                      ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (user.apodo.isNotEmpty)
                  Text(
                    "@${user.apodo}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- SECCIÓN: INFORMACIÓN ---
          ProfileSectionLabel(text: l10n.information),
          ProfileStyledCard(
            children: [
              ProfileInfoRowWidget(
                icon: Icons.email_outlined,
                label: l10n.emailAddress,
                value: user.email,
              ),
              if (user.descripcion.isNotEmpty) ...[
                const Divider(height: 1, indent: 50, color: Color(0xFFF0F0F0)),
                ProfileInfoRowWidget(
                  icon: Icons.description_outlined,
                  label: l10n.userDescription,
                  value: user.descripcion,
                ),
              ],
              const Divider(height: 1, indent: 50, color: Color(0xFFF0F0F0)),
              ProfileInfoRowWidget(
                icon: Icons.cake_outlined,
                label: l10n.birthdate,
                value: DateFormat('dd/MM/yyyy').format(user.fechaNacimiento),
              ),
              const Divider(height: 1, indent: 50, color: Color(0xFFF0F0F0)),
              ProfileInfoRowWidget(
                icon: Icons.calendar_month_outlined,
                label: l10n.memberSince,
                value: DateFormat('MMMM yyyy').format(user.fechaRegistro),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- SECCIÓN: PREFERENCIAS ---
          ProfileSectionLabel(text: l10n.preferredMode),
          ProfileStyledCard(
            children: [
              ProfileInfoRowWidget(
                icon: _isBike(user.modoPreferido)
                    ? Icons.directions_bike 
                    : Icons.electric_car,
                label: l10n.preferredMode,
                value: _isBike(user.modoPreferido) ? l10n.bicycle : l10n.car,
              ),
              const Divider(height: 1, indent: 50, color: Color(0xFFF0F0F0)),
              ProfileInfoRowWidget(
                icon: Icons.language,
                label: l10n.preferredLanguage,
                value: user.idiomaPreferido,
              ),
            ],
          ),
            
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}