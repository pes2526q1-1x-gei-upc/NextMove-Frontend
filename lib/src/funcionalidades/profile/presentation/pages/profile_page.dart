import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/footer_widget.dart';

// === IMPORTS DE WIDGETS PERSONALIZADOS ===
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/logout_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart'; 
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_menu_widgets.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/language_selector_widget.dart';

// === OTROS IMPORTS ===
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart'; 
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            
            String displayName = l10n.loading;
            String subText = l10n.waitAMoment;
            UserEntity? currentUser; 

            if (state is UserLoaded) {
              currentUser = state.user;
              displayName = "${l10n.hi}${state.user.nombreCompleto.split(' ').first}!";
              subText = "@${state.user.apodo}";
            } else if (state is UserUpdated) {
              currentUser = state.user;
              displayName = "${l10n.hi}${state.user.nombreCompleto.split(' ').first}!";
              subText = "@${state.user.apodo}";
            } else if (state is UserError) {
              displayName = l10n.ops;
              subText = l10n.errorLoadingProfile;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // --- HEADER ---
                    ProfileHeaderWidget(
                      title: displayName,
                      subtitle: subText,
                    ),
                    
                    const SizedBox(height: 30),

                    // --- SECCIÓN 1: CUENTA ---
                    ProfileSectionLabel(text: l10n.account),
                    ProfileStyledCard(
                      children: [
                        ProfileMenuOption(
                          icon: Icons.person_outline_rounded,
                          text: l10n.accountDetails,
                          onTap: () {
                            final userBloc = context.read<UserBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: userBloc,
                                  child: const EditUserDataPreferencesPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.block_rounded,
                          text: l10n.bloquedUsers,
                          onTap: () => debugPrint("Click en Bloqueados"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- SECCIÓN 2: PREFERENCIAS ---
                    ProfileSectionLabel(text: l10n.settings),
                    ProfileStyledCard(
                      children: [
                        ProfileMenuOption(
                          icon: Icons.language_rounded,
                          text: l10n.appLanguage,
                          onTap: () {
                            if (currentUser != null) {
                              // Usamos el widget refactorizado para mostrar el selector
                              ProfileLanguageSelector.show(context, currentUser);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.errorLoadingProfile)),
                              );
                            }
                          },
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.notifications_none_rounded,
                          text: l10n.notifications,
                          onTap: () => debugPrint("Click en Notificaciones"),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.dark_mode_outlined,
                          text: l10n.appearance,
                          onTap: () => debugPrint("Click en Modo Oscuro"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- BOTÓN LOGOUT ---
                    const ProfileLogoutButton(),
                    
                    const SizedBox(height: 20),

                    // --- FOOTER ---
                    const AppFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}