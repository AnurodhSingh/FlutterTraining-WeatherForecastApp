import 'package:flutter/material.dart';
import 'package:weather_forecast_app/model/weather_forecast_model.dart';
import 'package:weather_forecast_app/network/network.dart';
import 'package:weather_forecast_app/utils/convert_icon.dart';
import 'package:weather_forecast_app/utils/forecast_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Forecast screen
class ForecastScreen extends StatefulWidget {
  @override
  _ForecastScreenWidgetState createState() => _ForecastScreenWidgetState();
}

/// Forecast screen widget state
class _ForecastScreenWidgetState extends State<ForecastScreen> {
  Future<WeatherForecastModel> forecastObject;
  String cityName;

  @override
  void initState() {
    super.initState();
    getWeatherForCity('Indore');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ListView(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      children: [
        cityTextInput(),
        Container(
            height: MediaQuery.of(context).size.height * 0.90,
            child: FutureBuilder(
                future: forecastObject,
                builder: (BuildContext context,
                    AsyncSnapshot<WeatherForecastModel> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: Column(
                        children: [
                          detailWeatherView(snapshot),
                          spacer(10.0, 0.0),
                          weeklyWeatherView(snapshot),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return (Container(
                      alignment: Alignment.center,
                      child: Center(
                          child:
                              Text('No data available for the searched city.')),
                    ));
                  } else {
                    return (Container(
                      child: Center(child: CircularProgressIndicator()),
                    ));
                  }
                })),
      ],
    )));
  }

  Widget cityTextInput() {
    return Container(
      alignment: Alignment.center,
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Enter city name.',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(8.0)),
        onSubmitted: (_cityName) {
          getWeatherForCity(_cityName);
        },
      ),
    );
  }

  void getWeatherForCity(String _cityName) {
    setState(() {
      cityName = _cityName;
      forecastObject = Network().getWeatherForecast(cityName: _cityName);
    });
  }

  Widget detailWeatherView(AsyncSnapshot<WeatherForecastModel> snapshot) {
    final _city = snapshot.data.city.name;
    final _country = snapshot.data.city.country;
    final _dateTime = Utils.getFormattedDate(
        new DateTime.fromMillisecondsSinceEpoch(
            snapshot.data.forecasts[0].dt * 1000));
    final _temp =
        snapshot.data.forecasts[0].temp.day.toStringAsFixed(0) + '° F';
    final _weatherDescription =
        snapshot.data.forecasts[0].weather[0].description.toUpperCase();
    final _weatherType = snapshot.data.forecasts[0].weather[0].main;
    final _windSpeed =
        snapshot.data.forecasts[0].speed.toStringAsFixed(1) + ' mi/h';
    final _humidity = snapshot.data.forecasts[0].humidity.toString() + '%';
    final _maxTemp =
        snapshot.data.forecasts[0].temp.max.toStringAsFixed(0) + '° F';

    Widget detailView = Container(
      padding: EdgeInsets.only(top: 20.0),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          '$_city, $_country',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        Text(
          '$_dateTime',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        spacer(10.0, 0),
        getWeatherIcon(
            weatherType: _weatherType, size: 170.0, color: Colors.blueAccent),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              '$_temp',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            spacer(0, 10.0),
            Text(
              '$_weatherDescription',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ]),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(children: [
              Text(
                '$_windSpeed',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Icon(FontAwesomeIcons.wind, size: 20.0),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(children: [
              Text(
                '$_humidity',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Icon(FontAwesomeIcons.solidGrinBeamSweat, size: 20.0),
            ]),
          ),
          Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(children: [
                Text(
                  '$_maxTemp',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Icon(FontAwesomeIcons.temperatureHigh, size: 20.0),
              ]))
        ])
      ]),
    );
    return (detailView);
  }

  Widget weeklyWeatherView(AsyncSnapshot<WeatherForecastModel> snapshot) {
    return (Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          "7-Day Weather Forecast".toUpperCase(),
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Container(
            height: 170,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 8),
                itemCount: snapshot.data.forecasts.length,
                itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.0,
                      height: 160,
                      child: dayCardView(snapshot, index),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xFF9661C3), Colors.white],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight)),
                    ))))
      ],
    ));
  }

  Widget dayCardView(AsyncSnapshot<WeatherForecastModel> snapshot, int index) {
    var forecastList = snapshot.data.forecasts;
    var dayOfWeek = "";
    DateTime date =
        new DateTime.fromMillisecondsSinceEpoch(forecastList[index].dt * 1000);
    var fullDate = Utils.getFormattedDate(date);
    dayOfWeek = fullDate.split(",")[0];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dayOfWeek),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 33,
              backgroundColor: Colors.white,
              child: getWeatherIcon(
                  weatherType: forecastList[index].weather[0].main,
                  color: Colors.blueAccent,
                  size: 45),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                          "${forecastList[index].temp.min.toStringAsFixed(0)} °F"),
                    ),
                    Icon(
                      FontAwesomeIcons.solidArrowAltCircleDown,
                      color: Colors.white,
                      size: 17,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                          "${forecastList[index].temp.max.toStringAsFixed(0)} °F"),
                      Icon(
                        FontAwesomeIcons.solidArrowAltCircleUp,
                        color: Colors.white,
                        size: 17,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                          "Hum:${forecastList[index].humidity.toStringAsFixed(0)} %"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                          "Win:${forecastList[index].speed.toStringAsFixed(1)} mi/h"),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget spacer(double _height, double _width) {
    return (SizedBox(
      height: _height,
      width: _width,
    ));
  }
}
