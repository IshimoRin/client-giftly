import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftly/presentation/pages/login_page.dart'; // Импортируем LoginPage

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('Страница содержит все основные элементы', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      expect(find.text('Вход'), findsOneWidget);
      expect(find.text('Добро пожаловать в GIFTLY'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Забыли пароль?'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
      expect(find.text('Нет аккаунта?'), findsOneWidget);
      expect(find.text('Зарегистрироваться'), findsOneWidget);
    });

    testWidgets('Валидация: отображается ошибка при пустых полях', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      await tester.tap(find.text('Войти'));
      await tester.pump(); // для отображения ошибки

      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('Успешный ввод: ошибки не показываются', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите email'), findsNothing);
      expect(find.text('Введите пароль'), findsNothing);
      expect(
        find.byType(SnackBar),
        findsOneWidget,
      ); // проверка появления SnackBar
    });
  });
}
