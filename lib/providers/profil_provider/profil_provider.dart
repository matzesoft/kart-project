import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfilProvider extends ChangeNotifier {
  
}

class Profil {
  int id;
  String name;
  ThemeMode themeMode;
  int maxSpeed;
  int lightBrightness;
  Consumption consumption;

  Profil(
    this.id,
    this.name, {
    this.themeMode,
    this.maxSpeed,
    this.lightBrightness,
  });

  Map<String, Object> toMap() {
    return <String, Object>{
      "id": id,
      "name": name,
      "themeMode": themeMode,
      "maxSpeed": maxSpeed,
      "lightBrightness": lightBrightness,
      "consumption": consumption,
    };
  }
}

class Consumption {
  int consumptionBlueprint;

  Consumption({this.consumptionBlueprint});
}