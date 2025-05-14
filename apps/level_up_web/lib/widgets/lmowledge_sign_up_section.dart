import 'package:flutter/material.dart';

class KnowledgeSignupSection extends StatefulWidget {
  const KnowledgeSignupSection({super.key});

  @override
  State<KnowledgeSignupSection> createState() => _KnowledgeSignupSectionState();
}

class _KnowledgeSignupSectionState extends State<KnowledgeSignupSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Get Free Fitness Knowledge',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sign up for our weekly newsletter with fitness tips and exclusive content',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Your Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit the form
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanks for signing up!')),
                      );
                      _emailController.clear();
                    }
                  },
                  child: const Text('Sign Up for Free Content'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
