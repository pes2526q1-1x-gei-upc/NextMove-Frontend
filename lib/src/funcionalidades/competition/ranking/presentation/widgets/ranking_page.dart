import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/presentation/bloc/ranking_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/presentation/widgets/ranking_user_list.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/presentation/widgets/ranking_metric_selector.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String? selectedMetric;
  late RankingBloc _rankingBloc;

  @override
  void initState() {
    super.initState();
    selectedMetric = "calorias_quemadas";
    _rankingBloc = RankingBloc()..add(LoadRankingEvent(selectedMetric!));
  }

  @override
  void dispose() {
    _rankingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _rankingBloc,
      child: BlocListener<RankingBloc, RankingState>(
        listener: (context, state) {
          if (state is RankingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<RankingBloc, RankingState>(
          builder: (context, state) {
            return Scaffold(
              body: Column(
                children: [
                  RankingMetricSelector(
                    selectedMetric: selectedMetric,
                    onMetricChanged: (value) {
                      setState(() {
                        selectedMetric = value;
                      });
                      context.read<RankingBloc>().add(LoadRankingEvent(value!));
                    },
                  ),
                  const SizedBox(height: 16),
                  if (state is RankingLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is RankingLoaded)
                    Expanded(
                      child: RankingUserList(
                        selectedMetric: selectedMetric,
                        rankingData: state.rankingData,
                      ),
                    )
                  else if (state is RankingError)
                    Center(child: Text('Error: ${state.message}')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
