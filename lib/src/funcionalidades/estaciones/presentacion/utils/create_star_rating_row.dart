import 'package:flutter/material.dart';

Row createStarRatingRow(int rating) {
        List<Widget> stars = [];
        int fullStars = rating ~/ 2;
        bool hasHalfStar = rating % 2 == 1;

        for (int i = 0; i < fullStars; i++) {
            stars.add(const Icon(Icons.star, color: Colors.amber));
        }

        if (hasHalfStar) {
            stars.add(const Icon(Icons.star_half, color: Colors.amber));
        }
        
        while (stars.length < 5) {
            stars.add(const Icon(Icons.star_border, color: Colors.amber));
        }

        return Row(
            mainAxisSize: MainAxisSize.min,
            children: stars,
        );
    }