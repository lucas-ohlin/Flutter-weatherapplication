import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weatherapplication/services/weatherServices.dart';
import 'package:weatherapplication/models/weatherModel.dart';

class WeatherPage extends StatefulWidget {
    const WeatherPage({super.key});

    @override
    State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
    static const _apiKey = '9c533dbb948dcbf7613728fb87c506ed';
    //Check if it's on desktop or not
    final _weatherService = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS 
        ? WeatherService(_apiKey, true) : WeatherService(_apiKey, false);

    Weather? _weather;
    String? _error;
    bool _isloading = false;

    getWeather() async {
        
        setState(() {
            _isloading = true;
            _error = null;
        });

        try {
            String city = await _weatherService.getCityData();
            final weather = await _weatherService.getWeather(city);
            setState(() {
                _weather = weather;
                _isloading = false;
            });
        } catch (error) {
            setState(() {
                _error = error.toString();
                _isloading = false;
            });
        }
    }

    getWeatherAnimation(String? weatherCondition) {
        if (weatherCondition == null) return 'assets/sun.json';
        switch (weatherCondition.toLowerCase()) {
            case 'clouds':
                return 'assets/cloud.json';
            case 'rain':
                return 'assets/rain.json';
            case 'drizzle': 
                return 'assets/rain.json';
            case 'shower rain':
                return 'assets/rain.json';
            case 'thunderstorm':
                return 'assets/thunder.json';
            case 'clear':
                return 'assets/sun.json';
            default:
                return 'assets/sun.json';
        }
    }

    //Init State of the page, called on start
    @override
    void initState() {
        super.initState();
        getWeather();
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.grey[900],
            body: Center( 
                child: _isloading ? CircularProgressIndicator() 
                    : _error != null 
                        ? Text('Error : $_error')
                        : buildWeatherContent(), 
            ),
        );
    }

    Widget buildWeatherContent() {
        return Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text(
                    _weather?.city ?? "Loading city...",
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                    '${_weather?.condition}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
                ), 
                
                Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                        child: Lottie.asset(getWeatherAnimation(_weather?.condition))
                    ),
                ),

                Text(
                    '${_weather?.temp.round()}°', 
                    style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
                ),
            ],
        );
    }

}