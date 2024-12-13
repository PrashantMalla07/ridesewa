import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Ride Sharing App',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            SizedBox(height: 16),
            Text(
              'At Ridesewa, we value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, disclose, and safeguard your data when you use our services. By using our services, you agree to the practices described in this policy.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '1. Information We Collect',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We collect the following types of information:\n\n'
              '- Personal Information: Name, email address, phone number, payment details, location data.\n'
              '- Usage Data: IP address, device type, operating system version, browser type, usage statistics.\n'
              '- Location Data: Real-time location data to provide location-based services.\n'
              '- Payment Information: Transaction details, payment method details.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '2. How We Use Your Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We use the information we collect to:\n\n'
              '- Provide and improve the service.\n'
              '- Match riders with drivers.\n'
              '- Process payments and send receipts.\n'
              '- Offer customer support and resolve issues.\n'
              '- Send promotional communications (with your consent).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '3. How We Share Your Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We may share your information with:\n\n'
              '- Drivers: To enable them to provide the requested ride service.\n'
              '- Service Providers: Third-party vendors and service providers who assist us in operating our business.\n'
              '- Legal Compliance: When required by law, to protect our rights and safety, or to prevent fraud.\n'
              '- Business Transfers: In the case of a merger or acquisition.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '4. Data Retention',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We retain your personal information for as long as necessary to provide our services, comply with legal obligations, and resolve disputes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '5. Your Privacy Rights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Depending on your jurisdiction, you may have certain rights regarding your personal data, including:\n\n'
              '- The right to access, update, or delete your personal information.\n'
              '- The right to withdraw consent for data processing.\n'
              '- The right to object to or restrict the processing of your data.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '6. Security of Your Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We use industry-standard security measures to protect your personal information. However, no method of transmission or storage is 100% secure, and we cannot guarantee absolute security.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '7. Cookies and Tracking Technologies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We may use cookies and similar tracking technologies to enhance your experience with our service. You can control your cookie preferences through your browser settings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '8. Children’s Privacy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children. If we learn that we have inadvertently collected such data, we will take steps to delete it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '9. Changes to This Privacy Policy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated "Effective Date." We encourage you to review this policy periodically.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              '10. Contact Us',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions or concerns about this Privacy Policy, please contact us at:\n\n'
              '[customercare@ridesewa.com]\n[9816658815]',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
