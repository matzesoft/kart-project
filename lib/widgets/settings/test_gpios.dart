import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/extensions.dart';

class TestGpios extends StatefulWidget {
  @override
  _TestGpiosState createState() => _TestGpiosState();
}

class _TestGpiosState extends State<TestGpios> {
  final gpios = GpioInterface();
  GpioLine k1;
  GpioLine k2;
  GpioLine blueLight;

  @override
  void initState() {
    k1 = gpios.eLock;
    k2 = gpios.cruise;
    blueLight = gpios.ledBlue;
    super.initState();
  }

  void toggleK1() {
    k1.toggle();
  }

  void toggleK2() {
    k2.toggle();
  }

  void toggleBlueLight() {
    blueLight.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatButton(
          child: Text("K1"),
          onPressed: () => toggleK1(),
        ),
        FlatButton(
          child: Text("K2"),
          onPressed: () => toggleK2(),
        ),
        FlatButton(
          child: Text("Blue Light"),
          onPressed: () => toggleBlueLight(),
        ),
      ],
    );
  }
}
