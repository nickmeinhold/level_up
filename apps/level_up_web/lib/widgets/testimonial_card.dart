// widgets/testimonial_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestimonialCard extends StatelessWidget {
  final String name;
  final String text;
  final String imageUrl;
  final double rating; // Optional rating parameter

  const TestimonialCard({
    super.key,
    required this.name,
    required this.text,
    required this.imageUrl,
    this.rating = 5.0, // Default to 5 stars
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Stars
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 16),

            // Testimonial Text
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // User Info
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12),

                // Name and Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.robotoCondensed(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'LevelUp Athlete', // You could make this dynamic
                      style: GoogleFonts.roboto(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
