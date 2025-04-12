// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_web/widgets/coaching_card.dart';
import 'package:level_up_web/widgets/testimonial_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LevelUp Online Coaching',
          style: GoogleFonts.robotoCondensed(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              height: 500,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/1920x1080'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  'Transform Your Strength',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Programs Section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    'Our Programs',
                    style: GoogleFonts.robotoCondensed(fontSize: 36),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: const [
                      CoachingCard(
                        title: 'Basic Program',
                        price: 49.99,
                        features: ['Feature 1', 'Feature 2'],
                        productId: 'prod_basic',
                      ),
                      CoachingCard(
                        title: 'Advanced Program',
                        price: 99.99,
                        features: ['Feature 1', 'Feature 2', 'Feature 3'],
                        productId: 'prod_advanced',
                      ),
                      CoachingCard(
                        title: 'Elite Program',
                        price: 149.99,
                        features: ['All Features', '1-on-1 Coaching'],
                        productId: 'prod_elite',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Testimonials Section
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    'Success Stories',
                    style: GoogleFonts.robotoCondensed(fontSize: 36),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: const [
                      TestimonialCard(
                        name: 'John D.',
                        text: 'This program changed my training completely...',
                        imageUrl: 'https://via.placeholder.com/150',
                      ),
                      TestimonialCard(
                        name: 'Sarah K.',
                        text:
                            'The best investment I made in my athletic career...',
                        imageUrl: 'https://via.placeholder.com/150',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
