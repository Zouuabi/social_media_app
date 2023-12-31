import 'package:flutter/material.dart' show TextEditingController;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:social_media_app/core/failure/failure.dart';
import 'package:social_media_app/core/utils/strings_manager.dart';
import 'package:social_media_app/domain/use_cases/login_use_cases.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUseCase) : super(LoginInitial());

  final LoginUseCase _loginUseCase;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  bool _checkInput() {
    bool flag = false;
    if (_emailController.text.isEmpty) {
      flag = true;
      emit(const TextFieldEmpty(status: StringsManager.email));
    }
    if (_passwordController.text.isEmpty) {
      flag = true;
      emit(const TextFieldEmpty(status: StringsManager.password));
    }
    return flag;
  }

  Future<void> login() async {
    emit(LoginInitial());
    if (_checkInput()) return;

    emit(LoginLoading());

    final Either<Failure, void> result = await _loginUseCase.execute(
      LoginUseCaseInput(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
    // for the bad state error
    if (!isClosed) {
      emit(
        result.fold(
          (failure) => LoginError(message: failure.failureMessage),
          (userCred) => LoginLoaded(),
        ),
      );
    }
  }
}
