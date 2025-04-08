import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../../domain/usecases/login_usecase.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(LoginState.initial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginState.loading());
      final success = await loginUseCase(event.email, event.password);
      if (success) {
        emit(LoginState.success());
      } else {
        emit(LoginState.failure("Неверный логин или пароль"));
      }
    });
  }
}
