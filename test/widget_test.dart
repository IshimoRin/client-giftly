import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftly/presentation/pages/login_page.dart'; // Импортируем LoginPage

void main() {
  testWidgets('LoginPage displays login fields and button', (
    WidgetTester tester,
  ) async {
    // Строим приложение и вызываем рендеринг
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Проверяем, что на экране есть поле для ввода email
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);

    // Проверяем, что есть кнопка "Login"
    expect(find.byKey(const Key('loginButton')), findsOneWidget);

    // Проверяем, что есть кнопка "Create an Account"
    expect(find.byKey(const Key('registerButton')), findsOneWidget);
  });

  testWidgets('Navigate to RegisterPage when "Create an Account" is tapped', (
    WidgetTester tester,
  ) async {
    // Строим приложение и вызываем рендеринг
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Находим кнопку для регистрации
    final registerButton = find.byKey(const Key('registerButton'));
    expect(registerButton, findsOneWidget);

    // Тапаем по кнопке и ждем завершения навигации
    await tester.tap(registerButton);
    await tester.pumpAndSettle(); // Ожидаем завершения перехода

    // Проверяем, что мы на экране регистрации
    expect(
      find.byKey(const Key('emailFieldRegister')),
      findsOneWidget,
    ); // Проверяем наличие поля email для регистрации
  });
}
