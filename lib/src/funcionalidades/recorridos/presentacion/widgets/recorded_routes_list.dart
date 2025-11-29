import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/bloc/route_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/recorded_route_statistics.dart';
import 'package:provider/provider.dart';
import '../bloc/route_events.dart';
import '../bloc/route_state.dart';

class RouteHistoryList extends StatelessWidget {
  const RouteHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userEmail = userProvider.email!;
    return BlocProvider(
      create: (context) => RouteBloc()
        ..add(LoadRecordedRoutesEvent(userEmail)),
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteLoadingState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory), 
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is RouteErrorState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
              ),
              body: Center(child: Text('${l10n.error}: ${state.message}')), //ojo aqui con el state message, me puede dar problemas con los idiomas
            );
          } else if (state is RouteLoadedState) {
            final recorridos = state.recordedRoutes;

            if (recorridos.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.routeHistory),
                ),
                body: Center(
                  child: Text(l10n.noRoutesFound), // Añadir esta traducción
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
              ),
              body: ListView.builder(
                itemCount: recorridos.length,
                itemBuilder: (context, i) {
                  final recorrido = recorridos[i];
                  
                  return ListTile(
                    leading: Icon(
                      Icons.route,
                      color: Colors.blue,
                    ),
                    title: Text(
                      recorrido.timestamp.toLocal().toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${l10n.distance}: ${((recorrido.distance)/1000).toStringAsFixed(2)} km\n'
                      '${l10n.averageSpeed}: ${recorrido.averageSpeed!.toStringAsFixed(1)} km/h\n',
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // Implementar detalles del recorrido 
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecordedRouteStatistics(track: recorrido),
                        ),
                      );
                    },
                  );

                },
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
              ),
              body: Center(child: Text(l10n.unknownState)),
            );
          }
        },
      ),
    );
  }
}
