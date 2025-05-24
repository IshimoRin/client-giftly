import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class AIService {
  Future<String> getAIResponse(String question, List<Product> products) async {
    // Возвращаем стандартный ответ без использования ИИ
    return 'Извините, но в данный момент функция ИИ-помощника недоступна. Пожалуйста, просмотрите наш каталог букетов или обратитесь к менеджеру за помощью.';
  }
} 