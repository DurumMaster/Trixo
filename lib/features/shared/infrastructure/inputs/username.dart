import 'package:formz/formz.dart';

enum UsernameError { empty }

class Username extends FormzInput<String, UsernameError> {
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == UsernameError.empty) {
      return 'El nombre de usuario no puede estar vacío';
    }
    return null;
  }

  @override
  UsernameError? validator(String value) {
    if (value.isEmpty) return UsernameError.empty;
    return null;
  }
}
