import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('images/companybanner.jpg', fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              'About This Application',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This application is designed to help users manage their workouts and playlists efficiently. It provides a user-friendly interface to create, view, and play workout playlists.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'About The Company',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Our company is dedicated to providing the best fitness solutions to help you achieve your health goals. We believe in the power of technology to transform lives and make fitness accessible to everyone.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Contact Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phone: +65 98710455',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri(
                      scheme: 'tel',
                      path: '+6598710455',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      print('Could not launch $url');
                    }
                  },
                  child: Text("Call"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Email: blahblah@company.com',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri(
                      scheme: 'mailto',
                      path: 'blahblah@company.com',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      print('Could not launch $url');
                    }
                  },
                  child: Text("Email"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Developer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This application was developed by Jayden Lee, a passionate software developer with expertise in mobile application development.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
