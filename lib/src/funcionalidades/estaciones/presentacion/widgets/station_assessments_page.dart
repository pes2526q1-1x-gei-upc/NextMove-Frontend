import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/review_card_widget.dart';

class StationReviewsPage extends StatelessWidget {
  final String stationName;
  final Color themeColor;

  const StationReviewsPage({
    super.key,
    required this.stationName,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // CARGAR REVIEWS DE LA ESTACION.
    final List<Map<String, dynamic>> Reviews = [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), 
      appBar: AppBar(
        title: Text(
          l10n.opinions, 
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: Reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final review = Reviews[index];
          
          return ReviewCard(
            userName: review['user'],
            date: review['date'],
            rating: (review['rating']),
            comment: review['comment'],
            themeColor: themeColor,
          );
        },
      ),
    );
  }
}
