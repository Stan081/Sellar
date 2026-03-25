import 'package:flutter/material.dart';
import 'package:sellar/src/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Effective Date: March 2026',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing or using the Sellar application ("Service"), you agree '
                  'to be bound by these Terms of Service ("Terms"). If you do not '
                  'agree to these Terms, you may not access or use the Service. '
                  'These Terms apply to all visitors, users, and vendors who access '
                  'or use the Service.',
            ),
            _buildSection(
              context,
              '2. Description of Service',
              'Sellar is a mobile commerce platform that enables vendors to:\n\n'
                  '• List and manage products for sale\n'
                  '• Generate shareable payment links\n'
                  '• Accept payments through integrated payment gateways\n'
                  '• Share products on social media platforms\n'
                  '• Track sales analytics and customer insights\n\n'
                  'The Service is provided "as is" and we reserve the right to '
                  'modify, suspend, or discontinue any part of the Service at any time.',
            ),
            _buildSection(
              context,
              '3. Account Registration',
              'To use the Service, you must create an account by providing '
                  'accurate and complete information. You are responsible for:\n\n'
                  '• Maintaining the confidentiality of your account credentials\n'
                  '• All activities that occur under your account\n'
                  '• Notifying us immediately of any unauthorized use\n\n'
                  'You must be at least 18 years old and have the legal capacity '
                  'to enter into a binding agreement to use the Service.',
            ),
            _buildSection(
              context,
              '4. Vendor Obligations',
              'As a vendor using Sellar, you agree to:\n\n'
                  '• Provide accurate product descriptions, images, and pricing\n'
                  '• Fulfill orders promptly and in good faith\n'
                  '• Comply with all applicable laws and regulations\n'
                  '• Not sell prohibited, illegal, or counterfeit goods\n'
                  '• Handle customer data in accordance with applicable privacy laws\n'
                  '• Maintain fair and transparent business practices',
            ),
            _buildSection(
              context,
              '5. Payments and Fees',
              'Sellar facilitates payments through third-party payment processors. '
                  'By using the Service, you agree to the terms and fees of the '
                  'integrated payment gateway. Transaction fees, processing fees, '
                  'and any applicable taxes are the responsibility of the vendor. '
                  'Sellar is not responsible for payment disputes between vendors '
                  'and their customers.',
            ),
            _buildSection(
              context,
              '6. Intellectual Property',
              'The Service and its original content, features, and functionality '
                  'are owned by Sellar and are protected by international copyright, '
                  'trademark, and other intellectual property laws. You retain '
                  'ownership of content you upload (product images, descriptions) '
                  'but grant Sellar a non-exclusive license to use, display, and '
                  'distribute such content within the Service.',
            ),
            _buildSection(
              context,
              '7. Prohibited Activities',
              'You agree not to:\n\n'
                  '• Use the Service for any unlawful purpose\n'
                  '• Interfere with or disrupt the Service or servers\n'
                  '• Attempt to gain unauthorized access to any part of the Service\n'
                  '• Upload malicious code or content\n'
                  '• Impersonate another person or entity\n'
                  '• Use the Service to send spam or unsolicited communications\n'
                  '• Engage in fraudulent transactions or money laundering',
            ),
            _buildSection(
              context,
              '8. Limitation of Liability',
              'To the maximum extent permitted by law, Sellar shall not be liable '
                  'for any indirect, incidental, special, consequential, or punitive '
                  'damages, or any loss of profits or revenues, whether incurred '
                  'directly or indirectly, or any loss of data, use, goodwill, or '
                  'other intangible losses resulting from your use of the Service.',
            ),
            _buildSection(
              context,
              '9. Account Termination',
              'We reserve the right to suspend or terminate your account at any '
                  'time for violations of these Terms, fraudulent activity, or any '
                  'other reason we deem appropriate. You may also delete your account '
                  'at any time through the app settings or by contacting support.',
            ),
            _buildSection(
              context,
              '10. Changes to Terms',
              'We reserve the right to modify these Terms at any time. We will '
                  'provide notice of significant changes through the app or via '
                  'email. Your continued use of the Service after changes take '
                  'effect constitutes acceptance of the updated Terms.',
            ),
            _buildSection(
              context,
              '11. Contact Us',
              'If you have any questions about these Terms of Service, '
                  'please contact us at:\n\n'
                  'Email: legal@sellar.app\n'
                  'Website: https://sellar.app/terms',
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
