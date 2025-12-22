import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/domain/ranking_entry.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/friend_detail_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class RankingUserList extends StatelessWidget {
  const RankingUserList({
    super.key,
    required this.selectedMetric,
    required this.rankingData,
  });

  final String? selectedMetric;
  final List<RankingEntry> rankingData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: ValueKey(Theme.of(context).brightness),
      itemCount: rankingData.length,
      itemBuilder: (context, index) {
        final entry = rankingData[index];
        return RankingUserTile(
          entry: entry,
          selectedMetric: selectedMetric,
          position: index + 1,
        );
      },
    );
  }
}

class RankingUserTile extends StatefulWidget {
  const RankingUserTile({
    super.key,
    required this.entry,
    required this.selectedMetric,
    required this.position,
  });

  final RankingEntry entry;
  final String? selectedMetric;
  final int position;

  @override
  State<RankingUserTile> createState() => _RankingUserTileState();
}

class _RankingUserTileState extends State<RankingUserTile> {
  UserEntity? _userData;
  UserBloc? _userBloc;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _userBloc?.close();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _userBloc = UserBloc();
    _userBloc!.add(LoadUserProfileByEmail(widget.entry.email));
    
    // Listen to the bloc state changes
    _userBloc!.stream.listen((state) {
      if (state is UserLoaded) {
        if (mounted) {
          setState(() {
            _userData = state.user;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserEmail = userProvider.email;
    final isCurrentUser = widget.entry.email == currentUserEmail;

    final displayName = widget.entry.email;
    
    final hasPhoto = _userData?.photo.isNotEmpty == true;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<UserBloc>(
                    create: (context) {
                      final bloc = UserBloc();
                      bloc.add(LoadUserProfileByEmail(widget.entry.email));
                      return bloc;
                    },
                  ),
                  BlocProvider<SocialBloc>(
                    create: (context) => SocialBloc(),
                  ),
                ],
                child: const FriendDetailsPage(showSocialButtons: false),
              );
            },
          ),
        );
      },
      tileColor: isCurrentUser
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      shape: isCurrentUser
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            )
          : null,
      leading: Container(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            // Profile picture or default user icon
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: isCurrentUser
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 2,
                        )
                      : null,
                ),
                child: hasPhoto
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          _userData!.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 16,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
              ),
            ),
            // Position number overlay
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Text(
                  '${widget.position}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        widget.selectedMetric == 'calorias_quemadas'
            ? '${widget.entry.caloriesBurned ?? 0} kcal'
            : widget.selectedMetric == 'km_recorridos'
            ? '${widget.entry.distance ?? 0} km'
            : widget.selectedMetric == 'num_rutas'
            ? '${widget.entry.numberOfRoutes ?? 0}'
            : widget.selectedMetric == 'elevacion_positiva'
            ? '${widget.entry.elevationGain ?? 0} m'
            : widget.selectedMetric == 'co2_ahorrado'
            ? '${widget.entry.co2Saved ?? 0} kg'
            : widget.selectedMetric == 'num_retos_participados'
            ? '${widget.entry.challengesParticipated ?? 0}'
            : widget.selectedMetric == 'num_retos_completados'
            ? '${widget.entry.challengesCompleted ?? 0}'
            : '${widget.entry.elevationGain ?? 0} m',
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}
