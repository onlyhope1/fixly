import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Privacy Policy

Last updated: September 22, 2026

This is a dummy privacy policy for the Fixly app. 

1. Information We Collect
We collect information you provide directly to us, such as when you create or modify your account, request on-demand services, contact customer support, or otherwise communicate with us. This information may include: name, email, phone number, postal address, profile picture, payment method, items requested (for delivery services), delivery notes, and other information you choose to provide.

2. How We Use Information
We may use the information we collect about you to:
- Provide, maintain, and improve our Services.
- Perform internal operations.
- Send you communications.

3. Sharing of Information
We may share the information we collect about you as described in this Statement or as described at the time of collection or sharing, including as follows:
- With Service Providers.
- In response to a request for information by a competent authority.

4. Your Choices
Account Information
You may correct your account information at any time by logging into your online or in-app account.

Contact Us
If you have any questions about this Privacy Statement, please contact us.
''',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}
