part of 'atm_cubit.dart';

abstract class AtmState {
  final int balance;
  final Map<int, int> availableBanknotes;

  const AtmState({
    required this.balance,
    required this.availableBanknotes,
  });
}

class AtmInitial extends AtmState {
  const AtmInitial({
    required super.balance,
    required super.availableBanknotes,
  });
}

class WithdrawalSuccess extends AtmState {
  final Map<int, int> withdrawal;

  const WithdrawalSuccess({
    required super.balance,
    required super.availableBanknotes,
    required this.withdrawal,
  });
}

class WithdrawalError extends AtmState {
  final WithdrawalErrorReason reason;

  WithdrawalError({
    required this.reason,
    required AtmState state,
  }) : super(
          balance: state.balance,
          availableBanknotes: state.availableBanknotes,
        );
}

enum WithdrawalErrorReason {
  insufficientFunds,
  cannotWithdrawAmount,
}
