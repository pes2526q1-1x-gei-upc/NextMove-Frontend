import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/footer_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/language_selector_widget.dart';

// === IMPORTS DE WIDGETS PERSONALIZADOS ===
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/logout_button_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_menu_widgets.dart';

// === OTROS IMPORTS ===
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/blocked_users_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';

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

            // ===================================================================
            // STEP 1: Extract user data from BLoC state
            // ===================================================================
            // The UserBloc manages the user's profile data and emits different states
            // We need to handle each state to extract the user's information

            if (state is UserLoaded) {
              // User data has been successfully loaded from the backend
              currentUser = state.user;
              displayName =
                  "${l10n.hi}${state.user.nombreCompleto.split(' ').first}!";
              subText = "@${state.user.apodo}";
            } else if (state is UserUpdated) {
              // User data has been updated (e.g., after editing profile)
              currentUser = state.user;
              displayName =
                  "${l10n.hi}${state.user.nombreCompleto.split(' ').first}!";
              subText = "@${state.user.apodo}";
            } else if (state is UserError) {
              // Error occurred while loading user data
              displayName = l10n.ops;
              subText = l10n.errorLoadingProfile;
            }

            // ===================================================================
            // STEP 2: Extract the photo URL from the user entity
            // ===================================================================
            // CRITICAL CONCEPT: The user's photo URL is stored in user.photo
            // This URL points to the image stored in S3 (or other cloud storage)
            // We need to extract this ONLY if currentUser is not null

            String? userPhotoUrl;
            if (currentUser != null) {
              // User data exists - get the photo URL
              // The 'photo' field contains the full URL to the user's profile picture
              // Example: "https://bemotion-s3.s3.eu-west-3.amazonaws.com/img-perfil-user/profile-..."
              userPhotoUrl = currentUser.photo;

              // Debug log to help you understand what's happening
              if (userPhotoUrl != null && userPhotoUrl.isNotEmpty) {
                print('ProfilePage: User has photo URL: $userPhotoUrl');
              } else {
                print('ProfilePage: User has no photo (URL is null or empty)');
              }
            } else {
              // No user data available yet (loading or error state)
              userPhotoUrl = null;
              print('ProfilePage: Current user is null, cannot load photo');
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

                    // ===================================================================
                    // STEP 3: Pass the photo URL to ProfileHeaderWidget
                    // ===================================================================
                    // CRITICAL: This is where the magic happens!
                    // We pass the userPhotoUrl as the 'imageUrl' parameter
                    // The ProfileHeaderWidget will then:
                    // 1. Check if imageUrl is not null and not empty
                    // 2. If yes: use NetworkImage to load the photo from the URL
                    // 3. If no: show the default icon
                    //
                    // This is the EXACT SAME PATTERN used in edit_user_data_preferences.dart
                    // where we pass user.photo to ProfileAvatarSelector
                    ProfileHeaderWidget(
                      title: displayName,
                      subtitle: subText,
                      imageUrl:
                          userPhotoUrl, // <-- THE KEY LINE: passes the photo URL
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
                          onTap: () => {
                            // ignore: avoid_print
                            if (kDebugMode) {print("Click en Notificaciones")},
                          },
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuOption(
                          icon: Icons.dark_mode_outlined,
                          text: l10n.appearance,
                          onTap: () => {
                            // ignore: avoid_print
                            if (kDebugMode) {print("Click en Modo Oscuro")},
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- BOTÓN LOGOUT ---
                    const ProfileLogoutButton(),

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
