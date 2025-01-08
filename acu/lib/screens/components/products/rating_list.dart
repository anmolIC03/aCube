import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating; // Average rating (e.g., 4.5)
  final int ratingCount; // Total number of ratings

  const StarRating({
    Key? key,
    required this.rating,
    required this.ratingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Star icons
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star,
                color: Color.fromRGBO(251, 137, 4, 1), size: 16);
          } else if (index < rating) {
            return Icon(Icons.star_half,
                color: Color.fromRGBO(251, 137, 4, 1), size: 16);
          } else {
            return Icon(Icons.star_border,
                color: Color.fromRGBO(251, 137, 4, 1), size: 16);
          }
        }),
        SizedBox(width: 8),
        Text(
          "($ratingCount)",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
