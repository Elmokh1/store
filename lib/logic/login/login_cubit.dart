import 'package:firebase_auth/firebase_auth.dart';

import '../../data/my_database.dart';
import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  //Function

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = await MyDataBase.readUser(result.user?.uid ?? "");

      if (user == null) {
        emit(LoginFailure("User not found in database"));
        return;
      }
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure("Invalid email or password"));
    } catch (e) {
      emit(LoginFailure("Unexpected error: $e"));
    }
  }
}
