import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/delete_account_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/footer_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/language_selector_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/logout_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_menu_widgets.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/appearance_selector_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart'; // Import LoadUserProfile
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/blocked_users_page.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/user_statistics_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/social_page.dart';
import 'package:nextmove_app/src/funcionalidades/alertas/presentacion/bloc/alert_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/alertas/presentacion/pages/alerts_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _checkAndLoadUser();
  }

  void _checkAndLoadUser() {
    final userBloc = context.read<UserBloc>();
    final state = userBloc.state;
    if (state is UserInitial ||
        state is UserNeedsToSignUp ||
        state is UserError) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userBloc.add(LoadUserProfile(currentUser.uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            String displayName = l10n.loading;
            String subText = l10n.waitAMoment;
            UserEntity? currentUser;

            if (state is UserLoaded) {
              currentUser = state.user;
              displayName =
                  "${l10n.hi}${state.user.nombreCompleto.split(' ').first}!";
              subText = "@${state.user.apodo}";
            } else if (state is UserUpdated) {
              currentUser = state.user;
              displayName =
                  "${l10n.hi}${state.user.nombreCompleto.split(' ').first}!";
              subText = "@${state.user.apodo}";
            } else if (state is UserError) {
              displayName = l10n.ops;
              subText = l10n.errorLoadingProfile;
              // Attempt to recover potentially?
            } else if (state is UserNeedsToSignUp) {
              displayName = "Perfil incompleto";
              subText = "Necesitas completar tu registro";
            }

            String? userPhotoUrl;
            if (currentUser != null) {
              userPhotoUrl = currentUser.photo;
            } else {
              userPhotoUrl = null;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ProfileHeaderWidget(
                      title: displayName,
                      subtitle: subText,
                      imageUrl: userPhotoUrl,
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
                          icon: Icons.bar_chart_rounded,
                          text: l10n.myStatistics,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<UserBloc>(),
                                  child: const UserStatisticsPage(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // --- SECCIÓN 2: SOCIAL ---
                    ProfileSectionLabel(text: l10n.social),
                    ProfileStyledCard(
                      children: [
                        ProfileMenuOption(
                          icon: Icons.person_outline_rounded,
                          text: l10n.friends,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => SocialBloc(),
                                  child: const SocialPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.block_rounded,
                          text: l10n.bloquedUsers,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => SocialBloc(),
                                  child: const BlockedUsersPage(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // --- SECCIÓN 3: PREFERENCIAS ---
                    ProfileSectionLabel(text: l10n.settings),
                    ProfileStyledCard(
                      children: [
                        ProfileMenuOption(
                          icon: Icons.language_rounded,
                          text: l10n.appLanguage,
                          onTap: () {
                            if (currentUser != null) {
                              // Usamos el widget refactorizado para mostrar el selector
                              ProfileLanguageSelector.show(
                                context,
                                currentUser,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.errorLoadingProfile),
                                ),
                              );
                            }
                          },
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.notifications_none_rounded,
                          text: l10n.notifications,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => AlertBloc(),
                                  child: const AlertsPage(),
                                ),
                              ),
                            );
                          },
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.dark_mode_outlined,
                          text: l10n.appearance,
                          onTap: () => AppearanceSelector.show(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- BOTÓN LOGOUT ---
                    const ProfileLogoutButton(),

                    const SizedBox(height: 15),

                    // --- BOTÓN ELIMINAR CUENTA ---
                    const DeleteAccountButton(),

                    const SizedBox(height: 30),

                    // --- FOOTER ---
                    const AppFooter(),

                    const SizedBox(height: 20),
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
