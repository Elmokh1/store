import 'package:agri_store/logic/register/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/model/user_model.dart';
import '../../data/my_database.dart';
import '../../dialog_utils.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  //function
  FirebaseAuth authService = FirebaseAuth.instance;

  Future<void> register(String name, String email, String password) async {
    emit(RegisterLoading());
    try {
      var result = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var myUser = UserModel(
        name: name,
        email: email,
        id: result.user?.uid,
        password: password,
      );

      await MyDataBase.addUser(myUser);
      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(e.message ?? "Firebase Error"));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
