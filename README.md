# Kart Project

A [flutter-pi](https://github.com/ardera/flutter-pi)-app running on a RaspberryPi 4, being the infotainment system for a custom builded e-kart,
planned by two brothers.

## Features
### Driving information
To read the current speed and range are essential for every vehicle.

We are using the [KellyController KLS7245HC](https://kellycontroller.com/shop/kls-h/) to control the electric motor. This controller enables to read the driving information via CAN Bus.

### Lights control
To bring the kart to light we make us of two [2760lm leds](https://www.leds.de/nichia-nfcwl060b-v2-chip-on-board-modul-2760lm-5000k-cri-80-30608.html). By implementing PWM with the [wiringPi Library](http://wiringpi.com), you can switch between high beam and low beam.
Another feature PWM enables is to use the backlights aswell for brakelights by increasing the brightness whenever the driver is breaking.

Because we are using plexiglass for the bottom of the kart, we also added a lightstrip which colors can be controlled in the software aswell. The strip creates a nice looking shadow on the ground.

### Music control
We are using some old speakers to play music on the kart or to hoot. Playing music is enabled via Bluetooth. Any smartphone can connect and start playing. Currently it is not possible to control the music on the display. You have to use your phone to pause or switch between songs.

### Profil options
We had the idea of having multiple profiles, so when you are using the kart, all settings are adapted to your profil.

### Dark & Light theme
Having a dark and light theme has become normal for most modern apps. So why not adding it to our kart software?

### Map
We added a map using this [map](https://pub.dev/packages/map)-package. The data is saved locally on the Raspberry Pi in form of pngs. To also support dark and light theme, there are two types of data packages.

## Screenshots

### Mainscreen
![main_light](./screenshots/main_light.png)
![main_dark](./screenshots/main_dark.png)

### Settings
![profil_setting](./screenshots/profil_setting.png)
![light_setting](./screenshots/light_setting.png)

## Still in process...
Day for day we are moving on by developing - and we already made a big process. But there is still a lot of to do...

I already want to thank @ardera as the creator of [flutter-pi](https://github.com/ardera/flutter-pi) who already helped me in various situations.

If you already found some bad code,
something to improve or just have a question about the project at all feel free to open an issue or write an [e-mail](mailto:matzesoft@gmail.com).
