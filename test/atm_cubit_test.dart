import 'package:atm_simulator/manager/atm_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AtmCubit', () {
    late AtmCubit atmCubit;

    setUp(() {
      atmCubit = AtmCubit();
    });

    tearDown(() {
      atmCubit.close();
    });

    test('initial state is AtmInitial with correct balance and banknotes', () {
      expect(
        atmCubit.state,
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
    });

    blocTest<AtmCubit, AtmState>(
      'emits [WithdrawalError] when amount is greater than balance',
      build: () => atmCubit,
      act: (cubit) => cubit.withdraw(3000),
      expect: () => [
        isA<WithdrawalError>().having(
          (error) => error.reason,
          'reason',
          WithdrawalErrorReason.insufficientFunds,
        ),
      ],
    );

    blocTest<AtmCubit, AtmState>(
      'emits [WithdrawalError] when amount cannot be withdrawn with available banknotes',
      build: () => atmCubit,
      act: (cubit) => cubit.withdraw(35),
      expect: () => [
        isA<WithdrawalError>().having(
          (error) => error.reason,
          'reason',
          WithdrawalErrorReason.cannotWithdrawAmount,
        ),
      ],
    );

    blocTest<AtmCubit, AtmState>(
      'emits [WithdrawalSuccess] with correct balance and banknotes when withdrawal is possible',
      build: () => atmCubit,
      act: (cubit) => cubit.withdraw(580),
      expect: () => [
        isA<WithdrawalSuccess>()
            .having(
          (success) => success.balance,
          'balance',
          1420,
        )
            .having(
          (success) => success.availableBanknotes,
          'availableBanknotes',
          {
            200: 8,
            100: 19,
            50: 29,
            20: 39,
            10: 49,
          },
        ).having(
          (success) => success.withdrawal,
          'withdrawal',
          {
            200: 2,
            100: 1,
            50: 1,
            20: 1,
            10: 1,
          },
        ),
      ],
    );
  });
}
