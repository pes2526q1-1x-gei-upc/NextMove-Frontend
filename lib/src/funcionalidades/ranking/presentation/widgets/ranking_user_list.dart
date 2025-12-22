import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/ranking/domain/ranking_entry.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/friend_detail_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';

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
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
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
          title: Text(entry.email),
          subtitle: Text(
            selectedMetric == 'calorias_quemadas'
                ? '${entry.caloriesBurned ?? 0} kcal'
                : selectedMetric == 'km_recorridos'
                ? '${entry.distance ?? 0} km'
                : selectedMetric == 'num_rutas'
                ? '${entry.numberOfRoutes ?? 0}'
                : '${entry.elevationGain ?? 0} m',
          ),
        );
      },
    );
  }
}
