import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/domain/ranking_entry.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
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

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUserEmail = userProvider.email;
        final isCurrentUser = entry.email == currentUserEmail;

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
                          bloc.add(LoadUserProfileByEmail(entry.email));
                          return bloc;
                        },
                      ),
                      BlocProvider<SocialBloc>(
                        create: (context) => SocialBloc(),
                      ),
                    ],
                    child: const FriendDetailsPage(),
                  );
                },
              ),
            );
          },
          tileColor: isCurrentUser
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary,
              border: isCurrentUser
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 2,
                    )
                  : null,
            ),
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          title: Text(
            entry.email,
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            selectedMetric == 'calorias_quemadas'
                ? '${entry.caloriesBurned ?? 0} kcal'
                : selectedMetric == 'km_recorridos'
                ? '${entry.distance ?? 0} km'
                : selectedMetric == 'num_rutas'
                ? '${entry.numberOfRoutes ?? 0}'
                : '${entry.elevationGain ?? 0} m',
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        );
      },
    );
  }
}
