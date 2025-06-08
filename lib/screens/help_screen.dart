// lib/screens/help_center_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// A simple class to hold our FAQ data
class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class HelpCenterScreen extends StatelessWidget {
  HelpCenterScreen({Key? key}) : super(key: key);

  // --- List of Frequently Asked Questions ---
  // You can easily add, edit, or remove items from this list.
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'How do I book an appointment?',
      answer:
      'Navigate to the "Booking" tab from the main navigation bar. Select the service you need, choose an available time slot, and confirm your appointment. You can book for yourself or a selected family member.',
    ),
    FaqItem(
      question: 'How do I add a family member?',
      answer:
      'Go to the "Profile" tab and find the "Family Members" section. Tap "Add New" and fill in the required details for your family member. Once added, you can select them when booking services.',
    ),
    FaqItem(
      question: 'What are points and how do I use them?',
      answer:
      'You earn points for completing certain actions, like booking a service. These points can be redeemed for discounts on future services. Stay tuned for more ways to earn and use points!',
    ),
    FaqItem(
      question: 'Is my personal and medical data secure?',
      answer:
      'Absolutely. We use industry-standard encryption and security protocols to protect all your data. Your privacy and security are our top priorities.',
    ),
  ];

  // Helper method to launch URLs (email, phone, etc.)
  Future<void> _launchUrlHelper(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // In a real app, you'd show a more user-friendly error.
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        // Use the theme's color for the back button
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- FAQ Section ---
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._faqItems.map((item) {
            // ExpansionTile is a perfect widget for FAQs
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ExpansionTile(
                iconColor: theme.primaryColor,
                collapsedIconColor: theme.colorScheme.onSurface.withOpacity(0.7),
                title: Text(
                  item.question,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(item.answer),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // --- Contact Us Section ---
          const Text(
            'Still need help?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You can reach our support team directly.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _launchUrlHelper('mailto:support@example.com');
                },
                icon: const Icon(Icons.email),
                label: const Text('Email Us'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Remember to replace with your actual support phone number
                  _launchUrlHelper('tel:+1234567890');
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call Us'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}