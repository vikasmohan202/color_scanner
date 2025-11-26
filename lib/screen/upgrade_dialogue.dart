import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeDialog extends StatefulWidget {
  final bool isPlanExpired; // <-- NEW

  const UpgradeDialog({Key? key, this.isPlanExpired = false}) : super(key: key);

  @override
  State<UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<UpgradeDialog> {
  final String paymentUrl = "http://34.206.193.218:2425/";

  @override
  Widget build(BuildContext context) {
    bool isExpired = widget.isPlanExpired;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpired ? Icons.error_outline : Icons.workspace_premium,
                size: 40,
                color: isExpired ? Colors.red.shade700 : Colors.orange.shade700,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              isExpired ? 'Subscription Expired' : 'Free Trial Ended',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              isExpired
                  ? 'Your subscription has expired. Renew to continue accessing premium features.'
                  : 'You have used all your free scans. Subscribe to continue using premium features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // Features List
            _buildFeatureList(),

            const SizedBox(height: 24),

            // Payment Button
            ElevatedButton.icon(
              onPressed: _launchPaymentUrl,
              icon: const Icon(Icons.payment),
              label: Text(
                isExpired ? "Renew Subscription" : "Visit link to make payment",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isExpired
                    ? Colors.red.shade700
                    : Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isExpired ? 'Cancel' : 'Maybe Later',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureItem('Unlimited color scans'),
        _buildFeatureItem('High quality color detection'),
        _buildFeatureItem('Save your favorite colors'),
        _buildFeatureItem('Advanced color matching'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade500, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPaymentUrl() async {
    final Uri url = Uri.parse(paymentUrl);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open payment link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
