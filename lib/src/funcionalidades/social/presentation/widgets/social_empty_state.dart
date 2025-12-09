import 'package:flutter/material.dart';

class SocialEmptyState extends StatelessWidget {
  final bool isSearching;
  final String message;

  const SocialEmptyState({
    super.key,
    required this.isSearching,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.person_off_outlined : Icons.people_outline,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
