import 'dart:convert';
import 'package:http/http.dart';
import 'cards.dart';

var host = "http://localhost:8000";

class Requests {
  static Future<Cards> createCards(int size) async {
    var url = "$host/cards?size=$size";
    var response = await post(Uri.parse(url));
    dynamic body = json.decode(utf8.decode(response.bodyBytes));
    return Cards.fromJson(body);
  }

  static Future<Cards> shuffleCards(String id, {bool shuffleDiscard = false}) async {
    var url = "$host/cards/$id/shuffle?shuffle_discarded=$shuffleDiscard";
    var response = await post(Uri.parse(url));
    dynamic body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200) {
      throw Exception(body["message"]);
    } else {
      return Cards.fromJson(body);
    }
  }

  static Future deleteCards(String id) async {
    var url = "$host/cards/$id";
    await delete(Uri.parse(url));
  }

  static Future<Cards> takeCards(String id, {int nbCards = 1}) async {
    var url = "$host/cards/$id/take?lifo=true&length=$nbCards&move_as_block=false";
    var response = await post(Uri.parse(url));
    dynamic body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200) {
      throw Exception(body["message"]);
    } else {
      return Cards.fromJson(body);
    }
  }

  static Future<Cards> putCards(String id, {int nbCards = 1}) async {
    var url = "$host/cards/$id/put?lifo=false&length=$nbCards&move_as_block=true";
    var response = await post(Uri.parse(url));
    dynamic body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200) {
      throw Exception(body["message"]);
    } else {
      return Cards.fromJson(body);
    }
  }

  static Future<Cards> getCards(String id) async {
    var url = "$host/cards/" + id;
    var response = await get(Uri.parse(url));
    dynamic body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200) {
      throw Exception(body["message"]);
    } else {
      return Cards.fromJson(body);
    }
  }
}