import 'package:flutter/material.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@sellar.app',
      queryParameters: {'subject': 'Sellar App Support Request'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How can we help?',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions or reach out to our support team.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Contact options
            Text(
              'Contact Us',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@sellar.app',
              description: 'We typically respond within 24 hours',
              color: AppColors.primary,
              onTap: _launchEmail,
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.language,
              title: 'Visit Our Website',
              subtitle: 'sellar.app/help',
              description: 'Browse our full knowledge base',
              color: AppColors.info,
              onTap: () => _launchUrl('https://sellar.app/help'),
            ),
            const SizedBox(height: 28),

            // FAQ
            Text(
              'Frequently Asked Questions',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const _FAQItem(
              question: 'How do I create a payment link?',
              answer: 'Go to the Links tab and tap the "+" button. You can '
                  'optionally attach a product, set a custom amount, choose '
                  'a currency, and add a description. Once created, share '
                  'the link with your customers via any messaging platform.',
            ),
            const _FAQItem(
              question: 'How do I add a product?',
              answer: 'Navigate to the Products tab and tap the "+" button. '
                  'Fill in the product name, description, price, category, '
                  'and optionally upload images. Your product will be listed '
                  'and available for generating payment links.',
            ),
            const _FAQItem(
              question: 'Which payment gateways are supported?',
              answer: 'Sellar currently supports Paystack as the primary payment '
                  'gateway. We are actively working on adding support for Stripe, '
                  'Flutterwave, and other popular payment processors.',
            ),
            const _FAQItem(
              question: 'How do I connect my social media accounts?',
              answer: 'Go to Settings and tap on your profile card, then select '
                  '"Connected Accounts". From there, you can connect Facebook, '
                  'Instagram, WhatsApp, and TikTok to share products directly '
                  'to your social media channels.',
            ),
            const _FAQItem(
              question: 'Can I change my business currency?',
              answer: 'Yes! Go to Settings and tap on "Currency" to select your '
                  'preferred currency. This will be used as the default currency '
                  'for new products and payment links.',
            ),
            const _FAQItem(
              question: 'How do I track my sales?',
              answer: 'The Analytics tab provides a comprehensive overview of '
                  'your business performance, including revenue, orders, '
                  'conversion rates, top-selling products, and customer insights.',
            ),
            const _FAQItem(
              question: 'Is my data secure?',
              answer: 'Yes. We use industry-standard encryption and secure '
                  'authentication to protect your data. We never store your '
                  'payment credentials and use official OAuth for social media '
                  'connections. Read our Privacy Policy for full details.',
            ),
            const SizedBox(height: 28),

            // App version info
            Center(
              child: Column(
                children: [
                  Text(
                    'Sellar',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (Beta)',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
