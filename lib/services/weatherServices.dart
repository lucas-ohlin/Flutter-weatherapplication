import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/weatherModel.dart';
import 'package:http/http.dart' as http;

class WeatherService {
    static const baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
    final String apiKey;
    final bool isOnDesktop;

    WeatherService(this.apiKey, this.isOnDesktop);

    Future<Weather> getWeather(String city) async {
        //Result from API
        final res = await http.get(Uri.parse('$baseUrl?q=$city&APPID=$apiKey&units=metric'));

        if (res.statusCode == 200) {
            return Weather.fromJson(jsonDecode(res.body));
        } else {
            throw Exception('Failed to get weather data.');
        }
    }

    //Flutter has some trouble (at least on debug mode) to get the position of the user
    //when debbuging on desktop mode
    Future<String> getCityData() async {
        if (!isOnDesktop) {
            //Get permission from the user
            LocationPermission perms = await Geolocator.checkPermission();
            if (perms == LocationPermission.denied) {
                perms = await Geolocator.requestPermission();
            }

            if (perms == LocationPermission.whileInUse || perms == LocationPermission.always) {
                //Get the current position of the user
                Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                
                //Convert the location into a list of placemark objects & get the city
                List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
                String? city = placemark[0].locality;

                return city ?? "";
            } else {
                throw Exception('Location permission is denied.');
            }
            
        } else {
            //Mock city for desktop
            return 'Varberg';
        }
    }
}