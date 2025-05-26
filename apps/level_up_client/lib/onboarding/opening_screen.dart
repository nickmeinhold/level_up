import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/opening_screen.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextButton(
                          onPressed: () {
                            context.push('/intro-screen');
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15),
                            ),
                            foregroundColor: WidgetStateProperty.all<Color>(
                              Colors.red,
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.white,
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red),
                                  ),
                                ),
                          ),
                          child: Text('Try a free workout'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 10),
                        child: Divider(),
                      ),
                    ),
                    Text("OR"),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 30),
                        child: Divider(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextButton(
                          onPressed: () {
                            launchUrl(
                              Uri.parse('https://level-up-e4147.web.app'),
                            );
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15),
                            ),
                            foregroundColor: WidgetStateProperty.all<Color>(
                              Colors.white,
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.red,
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red),
                                  ),
                                ),
                          ),
                          child: Text('Subscribe'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
