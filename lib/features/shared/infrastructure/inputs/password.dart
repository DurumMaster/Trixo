import 'package:formz/formz.dart';

enum PasswordError { empty, length, format }

class Password extends FormzInput<String, PasswordError> {
  static final RegExp passwordRegExp =
      RegExp(r'(?:(?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$');
  static const int pswdMinLength = 6;

  const Password.pure() : super.pure('');

  const Password.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == PasswordError.empty) return 'Este campo es obligatorio';
    if (displayError == PasswordError.format) {
      return 'Debe contener mayúsculas, minúsculas y números';
    }
    if (displayError == PasswordError.length) {
      return 'Mínimo debe contener $pswdMinLength caracteres';
    }

    return null;
  }

  @override
  PasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return PasswordError.empty;
    if (!passwordRegExp.hasMatch(value)) return PasswordError.format;
    if (value.length < pswdMinLength) return PasswordError.length;

    return null;
  }
}
