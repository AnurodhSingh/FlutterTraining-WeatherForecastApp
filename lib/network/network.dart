import 'dart:convert';
import 'package:http/http.dart';
import 'package:weather_forecast_app/model/weather_forecast_model.dart';
import 'package:weather_forecast_app/utils/forecast_utils.dart';

class Network {
  Future<WeatherForecastModel> getWeatherForecast({String cityName}) async {
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast/daily?q=$cityName&appid=${Utils.appId}&units=metric';

    final response = await get(Uri.encodeFull(apiUrl));
    if (response.statusCode == 200) {
      return WeatherForecastModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error getting weather forecast.');
    }
  }
}
