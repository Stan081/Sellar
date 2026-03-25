import 'package:flutter/material.dart';
import 'package:sellar/src/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: March 2026',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Introduction',
              'Welcome to Sellar. We respect your privacy and are committed to '
                  'protecting the personal information you share with us. This Privacy '
                  'Policy explains how we collect, use, disclose, and safeguard your '
                  'information when you use our mobile application and services.',
            ),
            _buildSection(
              context,
              '2. Information We Collect',
              'We collect information you provide directly to us when you:\n\n'
                  '• Create an account (name, email, phone number, business name)\n'
                  '• Set up your business profile (country, currency preferences)\n'
                  '• Add products (product details, images, pricing)\n'
                  '• Generate payment links\n'
                  '• Connect social media accounts\n\n'
                  'We also automatically collect device information, usage data, '
                  'and analytics to improve our services.',
            ),
            _buildSection(
              context,
              '3. How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Provide, maintain, and improve our services\n'
                  '• Process transactions and send related information\n'
                  '• Send you technical notices, updates, and support messages\n'
                  '• Respond to your comments, questions, and requests\n'
                  '• Monitor and analyze trends, usage, and activities\n'
                  '• Detect, investigate, and prevent fraudulent transactions\n'
                  '• Personalize and improve your experience',
            ),
            _buildSection(
              context,
              '4. Information Sharing',
              'We do not sell, trade, or rent your personal information to third '
                  'parties. We may share your information only in the following '
                  'circumstances:\n\n'
                  '• With payment processors to complete transactions\n'
                  '• With social media platforms you explicitly connect\n'
                  '• To comply with legal obligations\n'
                  '• To protect our rights and prevent fraud\n'
                  '• With your consent or at your direction',
            ),
            _buildSection(
              context,
              '5. Data Security',
              'We implement appropriate technical and organizational security '
                  'measures to protect your personal information. This includes '
                  'encryption of sensitive data, secure authentication tokens, '
                  'and regular security assessments. However, no method of '
                  'transmission over the Internet is 100% secure.',
            ),
            _buildSection(
              context,
              '6. Data Retention',
              'We retain your personal information for as long as your account '
                  'is active or as needed to provide you services. You may request '
                  'deletion of your account and associated data at any time by '
                  'contacting our support team.',
            ),
            _buildSection(
              context,
              '7. Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate or incomplete data\n'
                  '• Request deletion of your data\n'
                  '• Opt out of marketing communications\n'
                  '• Export your data in a portable format\n'
                  '• Withdraw consent at any time',
            ),
            _buildSection(
              context,
              '8. Third-Party Services',
              'Our app may contain links to third-party websites and services. '
                  'We are not responsible for the privacy practices of these third '
                  'parties. We encourage you to read their privacy policies before '
                  'providing any personal information.',
            ),
            _buildSection(
              context,
              '9. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will '
                  'notify you of any changes by posting the new Privacy Policy '
                  'within the app and updating the "Last Updated" date. Your '
                  'continued use of the app after changes constitutes acceptance '
                  'of the updated policy.',
            ),
            _buildSection(
              context,
              '10. Contact Us',
              'If you have any questions about this Privacy Policy or our data '
                  'practices, please contact us at:\n\n'
                  'Email: privacy@sellar.app\n'
                  'Website: https://sellar.app/privacy',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
