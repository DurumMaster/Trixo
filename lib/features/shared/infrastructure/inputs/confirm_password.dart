import 'package:formz/formz.dart';

enum ConfirmPasswordError { mismatch }

class ConfirmPassword extends FormzInput<String, ConfirmPasswordError> {
  final String password;

  const ConfirmPassword.pure({this.password = ''}) : super.pure('');
  const ConfirmPassword.dirty({required String value, required this.password})
      : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == ConfirmPasswordError.mismatch) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  ConfirmPasswordError? validator(String value) {
    if (value != password) return ConfirmPasswordError.mismatch;
    return null;
  }
}
