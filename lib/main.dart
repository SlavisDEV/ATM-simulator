import 'package:atm_simulator/manager/atm_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATM Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => AtmCubit(),
        child: ATMPage(),
      ),
    );
  }
}

class ATMPage extends StatelessWidget {
  ATMPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AtmCubit, AtmState>(
      listener: (_, state) {
        if (state is WithdrawalError) {
          final String message = switch (state.reason) {
            WithdrawalErrorReason.insufficientFunds => 'Insufficient funds',
            WithdrawalErrorReason.cannotWithdrawAmount => 'Invalid amount',
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is WithdrawalSuccess) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Withdrawal successful'),
              content: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'You have withdrawn\n'),
                    ...state.withdrawal.entries.map(
                      (banknote) => TextSpan(
                        text: '- ${banknote.value} x ${banknote.key} PLN\n',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const TextSpan(text: 'from your account'),
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
            ),
          ).then((_) => _textEditingController.clear());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('ATM Simulator'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<AtmCubit, AtmState>(
                buildWhen: (_, current) => current is WithdrawalSuccess,
                builder: (_, state) {
                  return Text('Current balance: ${state.balance} PLN');
                },
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (int.parse(value) < 0) {
                      return 'Please enter a positive number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  final bool isDataValid = _formKey.currentState!.validate();
                  if (isDataValid) {
                    final int amount = int.parse(_textEditingController.text);
                    context.read<AtmCubit>().withdraw(amount);
                  }
                },
                child: const Text('Withdraw'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
