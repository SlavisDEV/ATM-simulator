import 'package:flutter/material.dart';

class WithdrawalSuccessDialog extends StatelessWidget {
  final Map<int, int> withdrawal;

  const WithdrawalSuccessDialog({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Withdrawal successful'),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            const TextSpan(text: 'You have withdrawn\n'),
            TextSpan(
              text: withdrawal.entries
                  .map(
                      (banknote) => '- ${banknote.value} x ${banknote.key} PLN')
                  .join('\n'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const TextSpan(text: '\nfrom your account'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
