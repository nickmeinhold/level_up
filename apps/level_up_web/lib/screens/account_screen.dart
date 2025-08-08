import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:level_up_web/services/subscription_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder(
          stream: locate<SubscriptionService>().subscriptionStatusStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // handle error
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            SubscriptionStatus status = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Email Section
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Email',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          locate<AuthService>().currentUserEmail!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Subscription Status Section
                if (status == SubscriptionStatus.incomplete)
                  IncompleteSubscriptionCard(),
                if (status == SubscriptionStatus.active)
                  ActiveSubscriptionCard(),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    context.go('/get-started');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    await locate<AuthService>().signOut();
                    if (context.mounted) context.go('/');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ActiveSubscriptionCard extends StatefulWidget {
  const ActiveSubscriptionCard({super.key});

  @override
  State<ActiveSubscriptionCard> createState() => _ActiveSubscriptionCardState();
}

class _ActiveSubscriptionCardState extends State<ActiveSubscriptionCard> {
  bool _cancelling = false;

  Future<void> _cancelSubscription() async {
    setState(() {
      _cancelling = true;
    });
    await locate<SubscriptionService>().cancelSubscription();
    setState(() {
      _cancelling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ), // Added rounded corners for better aesthetics
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Status',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Active Premium Subscription',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Renews on: January 1, 2025',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20), // Added spacing before the button
            // Subtle 'Cancel Subscription' button
            Align(
              alignment: Alignment.centerRight, // Align button to the right
              child:
                  _cancelling
                      ? const CircularProgressIndicator()
                      : TextButton(
                        onPressed: () async {
                          // Made onPressed async to await the dialog result
                          // Show confirmation dialog
                          final bool? confirmCancel = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: const Text('Cancel Subscription?'),
                                content: const Text(
                                  'Are you sure you want to cancel your subscription?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        dialogContext,
                                      ).pop(false); // User chose not to cancel
                                    },
                                    child: Text(
                                      'No, Keep Subscription',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(
                                        true,
                                      ); // User confirmed cancellation
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors
                                              .red, // Red button for destructive action
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Yes, Cancel'),
                                  ),
                                ],
                              );
                            },
                          );

                          // If user confirmed cancellation
                          if (confirmCancel == true) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Subscription cancellation initiated...',
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }

                            await _cancelSubscription();
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Subscription cancellation aborted.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Colors.red[700], // Subtle red text color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.red[200]!,
                            ), // Light red border
                          ),
                        ),
                        child: const Text(
                          'Cancel Subscription',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncompleteSubscriptionCard extends StatefulWidget {
  const IncompleteSubscriptionCard({super.key});

  @override
  State<IncompleteSubscriptionCard> createState() =>
      _IncompleteSubscriptionCardState();
}

class _IncompleteSubscriptionCardState
    extends State<IncompleteSubscriptionCard> {
  bool _retrievingSessionUrl = false;

  Future<void> _navigateToStripe() async {
    setState(() {
      _retrievingSessionUrl = true;
    });

    await locate<SubscriptionService>().processWebPayment();

    setState(() {
      _retrievingSessionUrl = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscription Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'INCOMPLETE',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Your sign up process is not yet complete',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            if (_retrievingSessionUrl) CircularProgressIndicator(),
            if (!_retrievingSessionUrl)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _navigateToStripe();
                  },
                  child: Text(
                    'Complete Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
