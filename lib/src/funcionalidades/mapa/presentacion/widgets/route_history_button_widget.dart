import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/recorded_routes_list.dart';

class RouteHistoryButtonWidget extends StatelessWidget {
  const RouteHistoryButtonWidget({
    super.key,
  });

  void _navigateToRouteHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RouteHistoryList(), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 130, // 70 + 50 (altura del botón anterior) + 10 (espacio)
      right: 16,
      child: GestureDetector(
        onTap: () => _navigateToRouteHistory(context),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.history, color: Colors.grey[700], size: 28),
        ),
      ),
    );
  }
}
