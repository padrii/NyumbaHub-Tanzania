import 'package:flutter/material.dart';

class ReviewStars extends StatelessWidget {
  final double rating;
  const ReviewStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.round();
    return Row(
      children: List.generate(5, (index) => Icon(
        index < fullStars ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 18,
      )),
    );
  }
}
