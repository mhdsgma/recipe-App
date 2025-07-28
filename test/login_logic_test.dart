import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_app/features/auth/domain/entities/app_user.dart';
import 'package:recipe_app/features/auth/domain/repos/auth_repo.dart';
import 'package:recipe_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:recipe_app/features/auth/presentation/cubits/auth_states.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepo mockAuthRepo;

  const testEmail = 'mhdraghban@gmail.com';
  const testPassword = '123456';
  final testUser = AppUser(uid: '1', email: testEmail, name: 'Test User');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    authCubit = AuthCubit(authRepo: mockAuthRepo);
  });

  tearDown(() async {
    await authCubit.close();
  });

  test('login success', () async {
    when(
      () => mockAuthRepo.loginWithEmailPassword(testEmail, testPassword),
    ).thenAnswer((_) async => testUser);

    expectLater(
      authCubit.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<Authenticated>().having(
          (state) => state.user.email,
          'email',
          testEmail,
        ),
      ]),
    );

    await authCubit.login(testEmail, testPassword);
  });
}
