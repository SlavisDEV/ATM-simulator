import 'package:flutter_bloc/flutter_bloc.dart';

part 'atm_state.dart';

class AtmCubit extends Cubit<AtmState> {
  AtmCubit()
      : super(
          const AtmInitial(
            balance: 2000,
            availableBanknotes: {
              200: 10,
              100: 20,
              50: 30,
              20: 40,
              10: 50,
            },
          ),
        );

  void withdraw(int amount) {
    int leftAmount = amount;
    if (amount > state.balance) {
      emit(
        WithdrawalError(
          reason: WithdrawalErrorReason.insufficientFunds,
          state: state,
        ),
      );
      return;
    }

    final Map<int, int> toWithdraw = {};

    for (final MapEntry<int, int> banknoteEntry
        in state.availableBanknotes.entries) {
      final int banknote = banknoteEntry.key;
      final int banknoteCount = banknoteEntry.value;
      final int banknotesToWithdraw = leftAmount ~/ banknote;

      if (banknotesToWithdraw > 0) {
        final availableBanknotesToWithdraw = banknotesToWithdraw > banknoteCount
            ? banknoteCount
            : banknotesToWithdraw;
        if (availableBanknotesToWithdraw > 0) {
          toWithdraw[banknote] = availableBanknotesToWithdraw;
          leftAmount -= banknote * availableBanknotesToWithdraw;
        }
      }
    }

    if (leftAmount > 0) {
      emit(
        WithdrawalError(
          reason: WithdrawalErrorReason.cannotWithdrawAmount,
          state: state,
        ),
      );
      return;
    }

    final Map<int, int> newAvailableBanknotes = {
      for (final MapEntry<int, int> banknoteEntry
          in state.availableBanknotes.entries)
        banknoteEntry.key:
            banknoteEntry.value - (toWithdraw[banknoteEntry.key] ?? 0),
    };

    emit(
      WithdrawalSuccess(
        balance: state.balance - amount,
        availableBanknotes: newAvailableBanknotes,
        withdrawal: toWithdraw,
      ),
    );
  }
}
